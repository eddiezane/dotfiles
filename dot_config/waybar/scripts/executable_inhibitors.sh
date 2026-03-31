#!/bin/bash

# Get the data once
MAP=$(hyprctl clients -j | jq -c '[.[] | select(.inhibitingIdle == true)]')
COUNT=$(echo "$MAP" | jq 'length')

# Get newline-separated titles
TITLES=$(echo "$MAP" | jq -r '.[].title')

if [ "$1" == "notify" ]; then
    if [ "$COUNT" -gt 0 ]; then
        notify-send "Active Idle Inhibitors" "$TITLES"
    else
        notify-send "Idle Inhibitors" "None"
    fi
    exit 0
fi

# Waybar JSON Output
if [ "$COUNT" -gt 0 ]; then
    # We use jq to build the JSON to ensure the tooltip (TITLES) 
    # is properly escaped so Waybar doesn't crash.
    jq -n -c --arg count "$COUNT" --arg titles "$TITLES" \
        '{"text": " \($count)", "tooltip": $titles, "class": "active"}'
else
    echo '{"text": " 0", "tooltip": "No active inhibitors", "class": "inactive"}'
fi
