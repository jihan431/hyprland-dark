#!/bin/bash
# Smart WiFi action: disconnect, connect saved, atau show password form
SSID="$1"
SECURITY="$2"
CFG="$HOME/dotfiles/eww"

# Cek apakah SSID ini sedang connected
ACTIVE=$(nmcli -t -f ACTIVE,SSID device wifi 2>/dev/null | awk -F: '/^yes/{print $2}')

if [ "$ACTIVE" = "$SSID" ]; then
    # Sedang connected → disconnect & forget
    ~/dotfiles/eww/scripts/wifi-disconnect.sh "$SSID"
    exit 0
fi

# Cek apakah sudah ada saved connection
if nmcli connection show "$SSID" > /dev/null 2>&1; then
    # Sudah pernah tersimpan → coba connect langsung
    notify-send "Wi-Fi" "Connecting to $SSID (saved)..." -i network-wireless
    if nmcli connection up "$SSID" > /dev/null 2>&1; then
        notify-send "Wi-Fi" "Connected to $SSID" -i network-wireless
        exit 0
    else
        # Gagal connect saved connection → mungkin password salah/berubah
        notify-send "Wi-Fi" "Saved connection failed. Please update password." -i network-wireless-error
        # Lanjut ke bawah untuk tampilkan form password
    fi
fi

# Jaringan baru atau saved connection yang gagal
if [ "$SECURITY" = "--" ] || [ -z "$SECURITY" ] || [[ "$SECURITY" != *"WPA"* && "$SECURITY" != *"WEP"* ]]; then
    # Open network → connect langsung
    notify-send "Wi-Fi" "Connecting to $SSID..." -i network-wireless
    nmcli device wifi connect "$SSID" && \
        notify-send "Wi-Fi" "Connected to $SSID" -i network-wireless || \
        notify-send "Wi-Fi" "Failed to connect" -i network-wireless-error
else
    # Butuh password → tampilkan form password native EWW
    eww --config "$CFG" update \
        connecting-ssid="$SSID" \
        wifi-password="" \
        show-password-form=true
fi
