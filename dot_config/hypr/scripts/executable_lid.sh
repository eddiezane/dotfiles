#!/usr/bin/env bash

if grep -q close /proc/acpi/button/lid/LID0/state; then
    hyprctl keyword monitor "eDP-1, disable"
else
    hyprctl keyword monitor "eDP-1, 2256x1504, 0x0, 1.333333"
fi
