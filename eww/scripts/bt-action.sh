#!/bin/bash
# Handle Bluetooth connection: Pair, Trust, and Connect
MAC="$1"
NAME="$2"

if [ -z "$MAC" ]; then
    exit 1
fi

notify-send "Bluetooth" "Attempting to connect to $NAME..." -i bluetooth

# Check if already paired
IS_PAIRED=$(bluetoothctl info "$MAC" | grep "Paired: yes")

if [ -z "$IS_PAIRED" ]; then
    notify-send "Bluetooth" "Pairing with $NAME..." -i bluetooth
    bluetoothctl pair "$MAC"
    # Wait a bit for pairing to settle
    sleep 2
fi

# Trust the device
bluetoothctl trust "$MAC" > /dev/null 2>&1

# Finally, connect
notify-send "Bluetooth" "Connecting to $NAME..." -i bluetooth
bluetoothctl connect "$MAC"

# Verify connection
sleep 2
if bluetoothctl info "$MAC" | grep -q "Connected: yes"; then
    notify-send "Bluetooth" "Connected to $NAME" -i bluetooth
else
    notify-send "Bluetooth" "Failed to connect to $NAME" -i bluetooth-error
fi
