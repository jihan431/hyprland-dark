#!/bin/bash
# Toggle BT panel. If opening while Bluetooth is ON, auto-start scan only when list is empty.
CFG="$HOME/dotfiles/eww"
CURRENT_STATE="${1:-false}"
BT_ENABLED="${2:-0}"
BT_COUNT="${3:-0}"

if [ "$CURRENT_STATE" = "true" ] || [ "$CURRENT_STATE" = "1" ]; then
    eww --config "$CFG" update show-bt=false
    exit 0
fi

eww --config "$CFG" update show-bt=true

if [ "$BT_ENABLED" = "1" ] && [ "$BT_COUNT" = "0" ]; then
    "$CFG/scripts/bt-scan.sh" >/dev/null 2>&1 &
fi
