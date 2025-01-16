#!/usr/bin/env bash

if pidof wlsunset; then
  pkill wlsunset
else
  loc=$(curl --fail https://ipinfo.io/loc)
  lat=$(echo "$loc" | cut -f 1 -d,)
  lon=$(echo "$loc" | cut -f 2 -d,)

  wlsunset -l "$lat" -L "$lon" -t 2500
fi
