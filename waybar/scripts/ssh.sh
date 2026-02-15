#!/bin/bash

# Cek apakah service sshd sedang berjalan
if systemctl is-active --quiet sshd; then
    # Jika sedang jalan, maka matikan
    sudo systemctl stop sshd
    notify-send "SSH Server" "SSH Dimatikan ❌" -u normal -t 3000
else
    # Jika sedang mati, maka hidupkan
    sudo systemctl start sshd
    notify-send "SSH Server" "SSH Dihidupkan ✅" -u normal -t 3000
fi
