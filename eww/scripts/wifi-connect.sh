#!/bin/bash
# Connect ke WiFi dengan password (dipanggil dari EWW password form)
SSID="$1"
PASSWORD="$2"

if [ -z "$SSID" ]; then exit 1; fi

if [ -n "$PASSWORD" ]; then
    notify-send "Wi-Fi" "Connecting to $SSID..." -i network-wireless
    nmcli device wifi connect "$SSID" password "$PASSWORD" && \
        notify-send "Wi-Fi" "Connected to $SSID" -i network-wireless || \
        notify-send "Wi-Fi" "Wrong password or failed" -i network-wireless-error
else
    notify-send "Wi-Fi" "Connecting to $SSID..." -i network-wireless
    nmcli device wifi connect "$SSID" && \
        notify-send "Wi-Fi" "Connected to $SSID" -i network-wireless || \
        notify-send "Wi-Fi" "Failed to connect" -i network-wireless-error
fi
