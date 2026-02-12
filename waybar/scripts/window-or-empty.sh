#!/bin/bash

# Cek kalau ada media player aktif dan lagi play
if playerctl status 2>/dev/null | grep -qi "playing"; then
    echo ""
    exit 0
fi

# Ambil info window aktif dari Hyprland
window_info=$(hyprctl activewindow -j)

# Kalau gak ada window, keluar
if [ -z "$window_info" ] || [ "$window_info" = "{}" ]; then
    echo ""
    exit 0
fi

# Ambil title
title=$(echo "$window_info" | jq -r '.title')

echo "$title"

