#!/bin/bash

# Cek governor sekarang
current=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)

if [[ "$current" == "performance" ]]; then
    # Mode hemat daya
    sudo cpupower frequency-set -g powersave
    notify-send "CPU Mode" "Powersave mode aktif"
else
    # Mode kenceng
    sudo cpupower frequency-set -g performance
    notify-send "CPU Mode" "Performance mode aktif"
fi
