#!/bin/bash
# Toggle wifi action panel: buka jika belum terbuka, tutup jika sudah terbuka dengan SSID yang sama
SSID="$1"
CFG="$HOME/dotfiles/eww"

CURRENT=$(eww --config "$CFG" get selected-wifi 2>/dev/null | tr -d '"')
SHOWING=$(eww --config "$CFG" get show-wifi-action 2>/dev/null)

if [ "$CURRENT" = "$SSID" ] && [ "$SHOWING" = "true" ]; then
    # Klik item yang sama saat sedang terbuka → tutup
    eww --config "$CFG" update show-wifi-action=false
else
    # Klik item baru atau saat tertutup → buka
    eww --config "$CFG" update show-wifi-action=true selected-wifi="$SSID"
fi
