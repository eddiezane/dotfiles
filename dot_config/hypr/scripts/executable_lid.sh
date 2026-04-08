#!/usr/bin/env bash

MONITOR_COUNT=$(hyprctl monitors -j | jq '. | length')

if grep -q close /proc/acpi/button/lid/LID0/state; then
    # LID IS CLOSED
    if [ "$MONITOR_COUNT" -gt 1 ]; then
        hyprctl keyword monitor "eDP-1, disable"
    else
        loginctl lock-session
        sleep 0.5
        systemctl suspend-then-hibernate
    fi
else
    # LID IS OPENED
    hyprctl keyword monitor "eDP-1, 2256x1504, 0x0, 1.333333"

    loginctl lock-session
fi
