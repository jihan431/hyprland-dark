#!/bin/bash

get_window_title_wayland() {
  if ! command -v hyprctl >/dev/null || ! command -v jq >/dev/null; then
    echo ""
    return
  fi
  title=$(hyprctl activewindow -j 2>/dev/null | jq -r '.title')
  if [[ "$title" == "null" ]]; then
    echo ""
  else
    echo "$title"
  fi
}

status=$(playerctl status 2>/dev/null | tr '[:upper:]' '[:lower:]')
jam=$(date '+%I:%M %p')

if [[ "$status" == "playing" ]]; then
  artist=$(playerctl metadata artist 2>/dev/null || echo "")
  title=$(playerctl metadata title 2>/dev/null || echo "")
  artist=${artist:-""}
  title=${title:-""}
  if [[ -n "$artist" && -n "$title" ]]; then
    echo "$jam | $artist - $title"
  elif [[ -n "$artist" || -n "$title" ]]; then
    echo "$jam | ${artist}${title}"
  else
    echo "$jam"
  fi
else
  window_title=$(get_window_title_wayland)
  if [[ -n "$window_title" ]]; then
    echo "$jam | $window_title"
  else
    echo "$jam"
  fi
fi
