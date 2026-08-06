#!/usr/bin/env sh

profile="$(
  busctl get-property \
    net.hadess.PowerProfiles \
    /net/hadess/PowerProfiles \
    net.hadess.PowerProfiles \
    ActiveProfile 2>/dev/null
)"
profile="${profile#s \"}"
profile="${profile%\"}"

if [ "${1:-}" = name ]; then
  printf '%s\n' "${profile:-unknown}"
  exit 0
fi

if [ "${1:-}" = cycle ]; then
  case "$profile" in
    balanced) next=performance ;;
    performance) next=power-saver ;;
    power-saver) next=balanced ;;
    *) next=balanced ;;
  esac
  powerprofilesctl set "$next"
  exit $?
fi

case "$profile" in
  performance) printf '󰤇\n' ;;
  balanced) printf '\n' ;;
  power-saver) printf '󰴻\n' ;;
  *) printf '\n' ;;
esac
