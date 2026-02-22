#!/bin/bash
# Trigger Bluetooth scanning in the background

notify-send "Bluetooth" "Scanning for nearby devices..." -i bluetooth

# Start scan for 15 seconds
bluetoothctl --timeout 15 scan on > /dev/null 2>&1

notify-send "Bluetooth" "Scan complete." -i bluetooth
