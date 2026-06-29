#!/usr/bin/env bash
# resume-dpms.sh — re-assert monitor DPMS-on after suspend/resume.
#
# Why a poll loop instead of a one-shot `hyprctl dispatch 'hl.dsp.dpms("on")'`:
# hypridle fires after_sleep_cmd the instant logind broadcasts
# PrepareForSleep=false, which can beat Hyprland/aquamarine finishing the DRM
# output re-acquire on resume. The early dpms-on is then accepted ("ok") but
# no-ops, leaving a connected/enabled eDP-1 powered down — black screen with
# dpmsStatus:0 even though the kernel connector and backlight are on (observed
# on a clean s2idle resume, 2026-06-27; manual hl.dsp.dpms("on") fixed it). See
# [[hibernate-resume-crash]] resume-side class. Polling until every *enabled*
# monitor reports dpmsStatus:1 wins the race regardless of how long the output
# takes to come back. dpms-on is idempotent, so re-issuing mid-reconfigure is
# safe.
#
# Disabled monitors (e.g. eDP-1 while docked, see lid.sh) report dpmsStatus
# false and must be ignored, or the loop would spin to its deadline every
# docked resume.

# Under the Lua config parser, bare `hyprctl dispatch dpms on` reparses to the
# invalid `hl.dispatch(dpms on)` and silently no-ops; call the dispatcher from
# the hl.dsp namespace directly. (See [[hyprctl-keyword-broken-under-lua]].)
dpms_on() { hyprctl dispatch 'hl.dsp.dpms("on")' >/dev/null 2>&1; }

# True while any enabled monitor is still powered down.
needs_on() {
    hyprctl monitors all -j 2>/dev/null \
        | jq -e 'any(.[]; .disabled == false and .dpmsStatus == false)' >/dev/null
}

deadline=$((SECONDS + 10))
while needs_on; do
    dpms_on
    if (( SECONDS >= deadline )); then
        echo "resume-dpms: gave up after 10s; a monitor still reports dpms-off"
        exit 1
    fi
    sleep 0.5
done
echo "resume-dpms: all enabled monitors dpms-on"
