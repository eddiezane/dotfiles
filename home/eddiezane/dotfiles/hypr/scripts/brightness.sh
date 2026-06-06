#!/usr/bin/env bash

# Usage: brightness-control.sh [up|down|max|min]

STEP="10%"

case $1 in
    up)
        brightnessctl s "$STEP"+
        ;;
    down)
        brightnessctl s "$STEP"-
        ;;
    max)
        brightnessctl s 100%
        ;;
    min)
        brightnessctl s 0%
        ;;
esac

BRIGHTNESS=$(brightnessctl -m | cut -d, -f4)

notify-send -u low -h string:x-canonical-private-synchronous:brightness "Brightness: $BRIGHTNESS"
