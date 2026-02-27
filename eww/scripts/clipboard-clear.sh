#!/bin/bash
# Clear clipboard history stored by cliphist.

CFG="$HOME/dotfiles/eww"

if ! command -v cliphist >/dev/null 2>&1; then
    notify-send "Clipboard" "cliphist is not installed" -i dialog-warning
    exit 1
fi

if cliphist wipe >/dev/null 2>&1; then
    eww --config "$CFG" update clipboard-list="[]" clipboard-count=0 clipboard-subtitle="Empty" >/dev/null 2>&1 || true
    notify-send "Clipboard" "History cleared" -i edit-clear
    exit 0
fi

notify-send "Clipboard" "Failed to clear history" -i dialog-error
exit 1
