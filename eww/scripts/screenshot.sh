#!/bin/bash

MODE=$1 # 'full' or 'region'
SAVE_DIR="$HOME/Pictures/Screenshot"
mkdir -p "$SAVE_DIR"

FILENAME="screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"
FILEPATH="$SAVE_DIR/$FILENAME"

case $MODE in
    "full")
        if grim "$FILEPATH"; then
            wl-copy < "$FILEPATH"
            notify-send "Screenshot" "Full screen saved to Screenshots/ and copied to clipboard" -i camera-photo
        else
            notify-send "Screenshot" "Full screen capture failed" -i error
        fi
        ;;
    "region")
        if grim -g "$(slurp)" "$FILEPATH"; then
            wl-copy < "$FILEPATH"
            notify-send "Screenshot" "Region saved to Screenshots/ and copied to clipboard" -i camera-photo
        else
            notify-send "Screenshot" "Capture cancelled or failed" -i camera-photo
        fi
        ;;
    *)
        echo "Usage: $0 {full|region}"
        exit 1
        ;;
esac
