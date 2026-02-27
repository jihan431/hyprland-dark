#!/bin/bash
# Restore selected cliphist entry back to clipboard using cliphist ID.

ITEM_ID="$1"

if [ -z "$ITEM_ID" ]; then
    exit 1
fi

if ! command -v cliphist >/dev/null 2>&1; then
    notify-send "Clipboard" "cliphist is not installed" -i dialog-warning
    exit 1
fi

RAW_LINE="$(cliphist list 2>/dev/null | awk -F'\t' -v id="$ITEM_ID" '$1==id{print; exit}')"
if [ -z "$RAW_LINE" ]; then
    notify-send "Clipboard" "Clipboard item not found" -i dialog-warning
    exit 1
fi

if command -v wl-copy >/dev/null 2>&1; then
    if printf '%s\n' "$RAW_LINE" | cliphist decode | wl-copy; then
        notify-send "Clipboard" "Copied from history" -i edit-copy
        exit 0
    fi
elif command -v xclip >/dev/null 2>&1; then
    if printf '%s\n' "$RAW_LINE" | cliphist decode | xclip -selection clipboard; then
        notify-send "Clipboard" "Copied from history" -i edit-copy
        exit 0
    fi
else
    notify-send "Clipboard" "No clipboard tool found (wl-copy/xclip)" -i dialog-warning
    exit 1
fi

notify-send "Clipboard" "Failed to copy from history" -i dialog-error
exit 1
