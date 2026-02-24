#!/usr/bin/env bash
# Toggle EWW Control Center
# Dipanggil via Waybar on-click

EWW_BIN="eww"
CFG_DIR="$HOME/dotfiles/eww"
WINDOW_NAME="control_center"

# Jalankan daemon EWW jika belum berjalan
if ! pgrep -x eww > /dev/null 2>&1; then
    "$EWW_BIN" --config "$CFG_DIR" daemon > /dev/null 2>&1
    sleep 0.3
fi

# Toggle: tutup jika terbuka, buka jika tertutup
if "$EWW_BIN" --config "$CFG_DIR" active-windows 2>/dev/null | grep -q "$WINDOW_NAME"; then
    "$EWW_BIN" --config "$CFG_DIR" close "$WINDOW_NAME"
else
    "$EWW_BIN" --config "$CFG_DIR" open "$WINDOW_NAME"
fi
