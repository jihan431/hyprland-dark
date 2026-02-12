#!/usr/bin/env bash

status=$(playerctl status 2>/dev/null | tr '[:upper:]' '[:lower:]')
if [[ "$status" == "playing" ]]; then
  artist=$(playerctl metadata artist 2>/dev/null || echo "")
  title=$(playerctl metadata title 2>/dev/null || echo "")
  echo "$artist - $title"
else
  echo "No media playing"
fi
