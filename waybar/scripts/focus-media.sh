#!/usr/bin/env bash
# Fokus window yang main media: spotify, vlc, youtube, firefox, chrome

players=("spotify" "vlc" "mpv" "youtube" "firefox" "chrome" "chromium")

for app in "${players[@]}"; do
  # Cari window yang title-nya mengandung nama app (case insensitive)
  window=$(hyprctl clients -j | jq -r --arg app "$app" '.[] | select(.title|test($app; "i")) | .address' | head -n1)
  if [[ -n "$window" ]]; then
    hyprctl dispatch focuswindow address:$window
    exit 0
  fi
done

# Kalau gak ketemu sama sekali, bisa kasih notif atau fallback
notify-send "Media Window" "No media player window found!"
