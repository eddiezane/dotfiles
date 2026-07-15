#!/usr/bin/env bash
set -uo pipefail

# Toggle wlsunset. On start, resolve location with graceful fallbacks so a
# missing network connection never leaves us without night-light:
#
#   1. geoclue2 (via the where-am-i client) -> cache the result
#   2. ipinfo.io                            -> cache the result
#   3. the last cached location
#   4. a hardcoded default (Denver, CO)
#
# geoclue is tried first because, when WiFi-AP geolocation works, it stays
# correct even behind a VPN / Tailscale exit node (unlike IP geolocation).

TEMP_NIGHT=2500
DEFAULT_LAT="39.7392"
DEFAULT_LON="-104.9903"

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/wlsunset"
cache_file="$cache_dir/location"

notify() {
  command -v notify-send >/dev/null 2>&1 && notify-send "wlsunset" "$1"
}

# Return 0 if the two args look like a valid lat,lon pair.
valid_coords() {
  [[ "$1" =~ ^-?[0-9]+(\.[0-9]+)?$ && "$2" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]
}

save_cache() {
  mkdir -p "$cache_dir"
  printf '%s\n%s\n' "$1" "$2" >"$cache_file"
}

if pidof wlsunset >/dev/null; then
  pkill wlsunset
  notify "night-light off"
  exit 0
fi

lat=""
lon=""

# 1. geoclue2. The where-am-i client keeps running to receive updates, so cap
#    it with a timeout and just parse the first location it prints.
if command -v geoclue-where-am-i >/dev/null 2>&1; then
  geo=$(timeout 8 geoclue-where-am-i -t 6 2>/dev/null || true)
  lat=$(awk -F: '/Latitude:/  {gsub(/[^0-9.-]/, "", $2); print $2; exit}' <<<"$geo")
  lon=$(awk -F: '/Longitude:/ {gsub(/[^0-9.-]/, "", $2); print $2; exit}' <<<"$geo")
  if valid_coords "$lat" "$lon"; then
    save_cache "$lat" "$lon"
  else
    lat="" lon=""
  fi
fi

# 2. ipinfo.io.
if ! valid_coords "$lat" "$lon"; then
  if loc=$(curl --fail --silent --max-time 5 https://ipinfo.io/loc); then
    lat=$(echo "$loc" | cut -f1 -d,)
    lon=$(echo "$loc" | cut -f2 -d,)
    if valid_coords "$lat" "$lon"; then
      save_cache "$lat" "$lon"
    else
      lat="" lon=""
    fi
  fi
fi

# 3. Fall back to cache.
if ! valid_coords "$lat" "$lon" && [[ -r "$cache_file" ]]; then
  { read -r lat; read -r lon; } <"$cache_file"
  valid_coords "$lat" "$lon" && notify "no location source; using cached location"
fi

# 4. Fall back to the hardcoded default.
if ! valid_coords "$lat" "$lon"; then
  lat="$DEFAULT_LAT"
  lon="$DEFAULT_LON"
  notify "no location available; using default ($lat, $lon)"
fi

exec wlsunset -l "$lat" -L "$lon" -t "$TEMP_NIGHT"
