#!/usr/bin/env bash
# lid.sh — Hyprland lid-switch handler (called from the switch:on/off:Lid Switch
# binds in hyprland.lua).
#
# Docked: disable the internal panel; Hyprland migrates its workspaces onto the
# externals. Re-enable on lid-open — reliable thanks to our local #14710
# backstop patch (pkgs/hyprland/scheduleReload-doLater-backstop.patch), which
# forces performMonitorReload() even when no monitor is rendering.
#
# Undocked: do nothing. Let systemd-logind's suspend-then-hibernate run without
# a racing monitor teardown into the (historically fragile) hibernate path, and
# never disable the only connected monitor (that drops the compositor into
# unsafe headless state right as the machine is suspending).
#
# Dock state is read from the same source logind uses to decide
# HandleLidSwitchDocked: a non-eDP DRM connector reporting "connected".

docked() {
    for s in /sys/class/drm/card*/status; do
        case "$s" in *eDP*) continue ;; esac   # ignore the internal panel
        [ "$(cat "$s" 2>/dev/null)" = connected ] && return 0
    done
    return 1
}

# NOTE: under the Lua config parser, `hyprctl keyword monitor ...` is rejected
# ("keyword can't work with non-legacy parsers. Use eval.") AND exits 0, so it
# silently no-ops. Runtime monitor changes must go through `hyprctl eval` with
# an hl.monitor() call instead.
case "$1" in
    close) docked && hyprctl eval 'hl.monitor({ output = "eDP-1", disabled = true })' ;;
    open)  hyprctl eval 'hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1.333333, disabled = false })' ;;
esac
