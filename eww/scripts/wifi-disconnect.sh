#!/bin/bash
# Disconnect dan Forget jaringan WiFi (Hapus profil agar minta password lagi)
SSID="$1"

if [ -z "$SSID" ]; then
    # Jika SSID tidak diberikan, cari yang sedang aktif
    SSID=$(nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | awk -F: '$2=="802-11-wireless"{print $1; exit}')
fi

if [ -n "$SSID" ]; then
    nmcli connection delete "$SSID"
    notify-send "Wi-Fi" "Forgot network: $SSID" -i network-wireless
fi
