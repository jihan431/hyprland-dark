#!/usr/bin/env bash

get_window_title() {
  local json
  json=$(hyprctl activewindow -j 2>/dev/null)
  if [[ -z "$json" ]]; then
    echo ""
  else
    echo "$json" | jq -r '.title // empty' 2>/dev/null
  fi
}

# Simpan status terakhir biar gak print output sama terus
last_output=""

playerctl --follow status 2>/dev/null | while read -r status; do
  status_lower=$(echo "$status" | tr '[:upper:]' '[:lower:]')

  if [[ "$status_lower" == "playing" ]]; then
    output=""  # kosongin window title pas media play
  else
    output=$(get_window_title)
    if [[ -z "$output" ]]; then
      output="No Window"
    fi
  fi

  # Cek kalau output berubah, baru echo
  if [[ "$output]()]()

