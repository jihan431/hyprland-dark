#!/bin/bash
# Toggle Bluetooth on/off dan update defvar EWW
CFG="$HOME/dotfiles/eww"

if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
    bluetoothctl power off
    eww --config "$CFG" update bt-enabled=0
else
    bluetoothctl power on
    eww --config "$CFG" update bt-enabled=1
fi
