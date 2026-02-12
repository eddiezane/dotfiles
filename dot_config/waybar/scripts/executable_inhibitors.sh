#!/bin/bash
# Count windows where inhibitingIdle is true
COUNT=$(hyprctl clients -j | jq '[.[] | select(.inhibitingIdle == true)] | length')

if [ "$COUNT" -gt 0 ]; then
    # Output for Waybar
    echo "{\"text\": \"󰈈 $COUNT\", \"tooltip\": \"Inhibitors: $COUNT\", \"class\": \"active\"}"
else
    echo "{\"text\": \"\", \"tooltip\": \"No active inhibitors\", \"class\": \"inactive\"}"
fi
