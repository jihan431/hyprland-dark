#!/bin/bash

DIR="$HOME/.config/hypr/wall"

INTERVAL=5

swww query || swww init

while true; do
    WALLPAPER=$(find "$DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" -o -name "*.jpeg" \) | shuf -n 1)
    if [ -n "$WALLPAPER" ]; then
        swww img "$WALLPAPER" --transition-type outer --transition-pos 0.85,0.85 --transition-step 60 --transition-fps 60
    fi
    sleep $INTERVAL
done
