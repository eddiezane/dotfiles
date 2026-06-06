#!/usr/bin/env bash

# Usage: volume-control.sh [up|down|mute|max|min]

STEP="5%"

case $1 in
  up)
    wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "$STEP"+
    ;;
  down)
    wpctl set-volume @DEFAULT_AUDIO_SINK@ "$STEP"-
    ;;
  mute)
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    ;;
  max)
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 1.0
    ;;
  min)
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 0
    ;;
esac

VOL_STATUS=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
VOLUME=$(echo "$VOL_STATUS" | awk '{print $2 * 100}')

if [[ "$VOL_STATUS" == *"[MUTED]"* ]]; then
  notify-send -u low -h string:x-canonical-private-synchronous:volume "Volume: Muted"
else
  notify-send -u low -h string:x-canonical-private-synchronous:volume "Volume: ${VOLUME}%"
fi
