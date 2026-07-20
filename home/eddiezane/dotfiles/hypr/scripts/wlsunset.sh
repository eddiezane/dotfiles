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

# Notify with a stable synchronous tag so each toast replaces the previous one
# (e.g. "locating…" becomes "night-light on") instead of stacking.
notify() {
  command -v notify-send >/dev/null 2>&1 &&
    notify-send -h "string:x-canonical-private-synchronous:wlsunset" "wlsunset" "$1"
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

notify "locating…"

lat=""
lon=""
src=""

# 1. geoclue2. The where-am-i client keeps streaming updates and won't exit on
#    its own, so run it in the background and kill it the instant the first
#    location lands — otherwise we'd block for the full -t timeout (the lag).
if command -v geoclue-where-am-i >/dev/null 2>&1; then
  geo_tmp=$(mktemp)
  geoclue-where-am-i -t 10 >"$geo_tmp" 2>/dev/null &
  gc_pid=$!
  for _ in $(seq 1 30); do                       # poll up to ~6s
    grep -q "Longitude:" "$geo_tmp" && break
    kill -0 "$gc_pid" 2>/dev/null || break        # client died early
    sleep 0.2
  done
  kill "$gc_pid" 2>/dev/null
  wait "$gc_pid" 2>/dev/null

  lat=$(awk -F: '/Latitude:/  {gsub(/[^0-9.-]/, "", $2); print $2; exit}' "$geo_tmp")
  lon=$(awk -F: '/Longitude:/ {gsub(/[^0-9.-]/, "", $2); print $2; exit}' "$geo_tmp")
  rm -f "$geo_tmp"

  if valid_coords "$lat" "$lon"; then
    src="geoclue"
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
      src="ipinfo"
      save_cache "$lat" "$lon"
    else
      lat="" lon=""
    fi
  fi
fi

# 3. Fall back to cache.
if ! valid_coords "$lat" "$lon" && [[ -r "$cache_file" ]]; then
  { read -r lat; read -r lon; } <"$cache_file"
  valid_coords "$lat" "$lon" && src="cache"
fi

# 4. Fall back to the hardcoded default.
if ! valid_coords "$lat" "$lon"; then
  lat="$DEFAULT_LAT"
  lon="$DEFAULT_LON"
  src="default"
fi

notify "night-light on ($lat, $lon via $src)"
exec wlsunset -l "$lat" -L "$lon" -t "$TEMP_NIGHT"
