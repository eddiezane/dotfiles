#!/usr/bin/env bash

pkill wlsunset

loc=$(curl --fail https://ipinfo.io/loc)
lat=$(echo "$loc" | cut -f 1 -d,)
lon=$(echo "$loc" | cut -f 2 -d,)

wlsunset -l "$lat" -L "$lon"
