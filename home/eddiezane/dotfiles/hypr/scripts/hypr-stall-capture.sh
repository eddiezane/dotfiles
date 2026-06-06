#!/usr/bin/env bash
# Capture Hyprland state when it wedges post-hibernate-resume (black screen,
# process still alive). Run over SSH from a phone instead of power-buttoning;
# then `sudo systemctl reboot` cleanly so any coredump survives.
#
# Path: installed on $PATH as `hypr-stall-capture` via writeShellScriptBin in
# hyprland.nix — also lives at ~/.config/hypr/scripts/ as the source-of-truth.

set -uo pipefail

PID=$(pidof Hyprland || true)
if [ -z "${PID:-}" ]; then
  echo "Hyprland is not running — nothing to capture" >&2
  exit 1
fi

OUT="$HOME/hypr-stall-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT"
cd "$OUT" || exit 1

{
  echo "Hyprland pid: $PID"
  date -u
  hostname
  uname -a
} > README.txt

# Userspace-visible state (no root)
ps -p "$PID" -o pid,stat,rss,vsz,etime,wchan=WIDE-WCHAN > ps.txt 2>&1
cp /proc/"$PID"/status  status.txt  2>/dev/null
cp /proc/"$PID"/wchan   wchan.txt   2>/dev/null
cp /proc/"$PID"/syscall syscall.txt 2>/dev/null

# Per-thread (the renderer thread is usually the wedged one)
{
  for t in /proc/"$PID"/task/*; do
    tid=$(basename "$t")
    comm=$(cat "$t/comm"  2>/dev/null)
    wchan=$(cat "$t/wchan" 2>/dev/null)
    printf "tid=%-7s comm=%-15s wchan=%s\n" "$tid" "$comm" "$wchan"
  done
} > threads.txt 2>&1

# Kernel stacks (root). One sudo invocation, one YubiKey tap. Will prompt
# interactively; if you skip / it fails, the rest of the capture still runs.
echo ">>> sudo needed for kernel stacks — tap YubiKey if prompted (or Ctrl-C to skip)"
if sudo bash -s "$PID" "$OUT" <<'ROOT_BLOCK'
set -u
pid=$1
out=$2
cat /proc/"$pid"/stack > "$out/stack.txt" 2>/dev/null
{
  for t in /proc/"$pid"/task/*; do
    tid=$(basename "$t")
    comm=$(cat "$t/comm" 2>/dev/null)
    echo "=== tid $tid ($comm) ==="
    cat "$t/stack" 2>/dev/null
    echo
  done
} > "$out/thread-stacks.txt" 2>/dev/null
ROOT_BLOCK
then
  echo "(kernel stacks captured)" >> README.txt
else
  echo "(sudo declined/failed — kernel stacks skipped)" >> README.txt
fi

# Hyprland's signature: the IPC socket lives at $XDG_RUNTIME_DIR/hypr/$SIG/,
# so the dir name IS the signature. Beats reading /proc/PID/environ — that
# requires sudo (CAP_SYS_NICE → non-dumpable), and Hyprland's own environ
# doesn't contain HYPRLAND_INSTANCE_SIGNATURE anyway; it generates the sig
# post-startup and only injects it into spawned children.
HIS=$(ls -1 "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr/" 2>/dev/null | head -1)
if [ -n "$HIS" ]; then
  export HYPRLAND_INSTANCE_SIGNATURE="$HIS"
  echo "HYPRLAND_INSTANCE_SIGNATURE=$HIS" >> README.txt
fi

# Hyprland IPC alive? Only flag a wedge if hyprctl actually times out
# (exit 124 from `timeout`). Other exits = it ran and either succeeded or
# fast-failed; the file content tells you which.
timeout 5 hyprctl monitors -j  > monitors.json  2>&1; rc=$?
[ "$rc" -eq 124 ] && echo "(hyprctl monitors TIMED OUT — IPC actually wedged)" >> README.txt
timeout 5 hyprctl version      > version.txt    2>&1
timeout 5 hyprctl systeminfo   > systeminfo.txt 2>&1
timeout 5 hyprctl clients -j   > clients.json   2>&1

# Recent compositor + kernel graphics activity
journalctl --user -b -u 'wayland-wm@hyprland.desktop.service' --since "10 min ago" \
  > hyprland-stderr.log 2>&1
journalctl -b --since "10 min ago" \
  | grep -iE 'amdgpu|drm|pm:|hibernat|resume|suspend' \
  > kernel-gfx.log 2>&1

# DRM connector view — kernel's truth about which outputs are plugged in.
# Critical for diagnosing the "Hyprland sees 0 monitors / falls back to
# headless" post-resume bug: if eDP-1 here says "connected" but hyprctl
# monitors returns [] or "Panel FALLBACK", the kernel saw the panel come
# back and Hyprland missed the hotplug event.
{
  for f in /sys/class/drm/card*-*/status; do
    printf "%-40s %s\n" "$f" "$(cat "$f")"
  done
} > drm-connectors.txt 2>&1

# `hyprctl monitors -j` queries `m_monitors` (active enabled). `monitors
# all` queries `m_realMonitors` (everything — disabled, FALLBACK, etc.).
# If `[]` vs `all` differ, the real monitor wrapper survived suspend but
# got disabled/orphaned. If both are empty (or only show FALLBACK), the
# wrapper was actually destroyed → output->events.destroy fired in
# aquamarine somewhere during suspend prep. Different bugs, different fix.
timeout 5 hyprctl monitors all -j > monitors-all.json 2>&1

# Aquamarine's debug log + Hyprland's own runtime log. Aquamarine logs
# `drm: Restoring after VT switch`, `drm: Connector X disconnected`,
# `drm: crtc X failed restore`, etc. into here — NOT into the systemd
# journal. This is the single most diagnostic file for the post-resume
# wedge: tells us whether restoreAfterVT() actually ran and what
# recheckOutputs() did with eDP-1. Lives in tmpfs so it's lost on reboot
# — we copy it out NOW before anything kills the session.
HYPRLOG="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr/$HIS/hyprland.log"
[ -f "$HYPRLOG" ] && cp "$HYPRLOG" hyprland-runtime.log 2>/dev/null
# Also grab the tail focused on the resume window for quick reading.
if [ -f hyprland-runtime.log ]; then
  grep -niE 'restoring|recheck|connector|disconnect|connect|crtc|modeset|commit|page-?flip|fallback|headless' \
    hyprland-runtime.log > hyprland-resume-events.log 2>&1 || true
fi

echo
echo "Captured to: $OUT"
echo

# Auto-recovery cascade. Bug we keep reproducing: Hyprland tore down its
# eDP-1 monitor (silently, in aquamarine's session-pause path during
# suspend), then never recreated it after resume — falls back to headless.
# Kernel still sees eDP-1 connected. Try increasingly invasive nudges in
# order, stop at the first that brings monitors back.
#
# Ctrl-C during the 3s pause skips recovery entirely (e.g. for A/B tests).
echo
echo ">>> Recovery cascade starts in 3s (Ctrl-C to skip)"
sleep 3

# Helper: returns 0 if Hyprland reports a non-empty monitor list.
monitors_back() {
  [ -n "${HIS:-}" ] || return 1
  out=$(timeout 5 hyprctl monitors -j 2>/dev/null || true)
  [ -n "$out" ] && [ "$out" != "[]" ]
}

recovered=""

# 1) Force a real disconnect→reconnect transition on the DRM connector,
#    so the kernel emits actual state-change uevents (writing `detect` to
#    an already-connected output is a no-op). Sudo timestamp from the
#    kernel-stack capture above is still valid (~5min), so usually no
#    second YubiKey tap.
EDP=$(ls /sys/class/drm/card*-eDP-1/status 2>/dev/null | head -1)
if [ -n "$EDP" ]; then
  echo "[1/3] Connector cycle (off → detect) on $EDP"
  sudo sh -c "echo off > '$EDP' && sleep 1 && echo detect > '$EDP'" \
    && sleep 2 \
    && monitors_back \
    && recovered="connector-cycle"
fi

# 2) Ask Hyprland to re-read its config, which re-runs the monitor rules
#    and may force re-acquisition of eDP-1 even without a kernel uevent.
if [ -z "$recovered" ] && [ -n "${HIS:-}" ]; then
  echo "[2/3] hyprctl reload"
  hyprctl reload >/dev/null 2>&1 \
    && sleep 2 \
    && monitors_back \
    && recovered="hyprctl-reload"
fi

# 3) Last resort before reboot: tell Hyprland directly to add eDP-1.
if [ -z "$recovered" ] && [ -n "${HIS:-}" ]; then
  # Lua config parser rejects `hyprctl keyword` (silent no-op, exits 0); the
  # runtime monitor add must go through `hyprctl eval` + hl.monitor() instead.
  echo "[3/3] hyprctl eval hl.monitor eDP-1 (re-add)"
  hyprctl eval 'hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1, disabled = false })' >/dev/null 2>&1 \
    && sleep 2 \
    && monitors_back \
    && recovered="hyprctl-keyword-monitor"
fi

echo
if [ -n "$recovered" ]; then
  echo "✓ Recovered via: $recovered"
  echo "(Note this in the capture's README — tells us which fix works.)"
  echo "$recovered" >> README.txt
else
  echo "✗ All three recovery attempts failed."
  echo "Reboot cleanly: sudo systemctl reboot"
  echo "FAILED" >> README.txt
fi
