#!/bin/bash
# Cek status Radio WiFi menggunakan nmcli
# Output: 1 (Enabled), 0 (Disabled)

if nmcli radio wifi | grep -q "enabled"; then
    echo 1
else
    echo 0
fi
