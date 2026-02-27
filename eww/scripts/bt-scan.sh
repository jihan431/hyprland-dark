#!/bin/bash
# Trigger Bluetooth scanning in the background with notifications.
CFG="$HOME/dotfiles/eww"

adapters() {
    for path in /sys/class/bluetooth/hci*; do
        [ -e "$path" ] || continue
        basename "$path"
    done
}

controller_addrs() {
    for a in $(adapters); do
        [ -r "/sys/class/bluetooth/$a/address" ] || continue
        cat "/sys/class/bluetooth/$a/address"
    done
}

if ! "$CFG/scripts/bt-status.sh" | grep -q '^1$'; then
    notify-send "Bluetooth" "Bluetooth is off" -i bluetooth
    exit 0
fi

if [ -z "$(adapters)" ]; then
    notify-send "Bluetooth" "No controller detected" -i bluetooth
    exit 0
fi

notify-send "Bluetooth" "Scanning for nearby devices..." -i bluetooth

# Start discovery through DBus (works even when bluetoothctl default controller is missing).
for a in $(adapters); do
    busctl --system call org.bluez "/org/bluez/$a" org.bluez.Adapter1 StartDiscovery >/dev/null 2>&1 || true
done

# Fallback/assist for setups where default controller is missing.
did_scan_controller=0
for addr in $(controller_addrs); do
    did_scan_controller=1
    bluetoothctl --controller "$addr" scan on >/dev/null 2>&1 || true
done
if [ "$did_scan_controller" -eq 0 ]; then
    bluetoothctl scan on >/dev/null 2>&1 || true
fi

sleep 12

for a in $(adapters); do
    busctl --system call org.bluez "/org/bluez/$a" org.bluez.Adapter1 StopDiscovery >/dev/null 2>&1 || true
done
for addr in $(controller_addrs); do
    bluetoothctl --controller "$addr" scan off >/dev/null 2>&1 || true
done
bluetoothctl scan off >/dev/null 2>&1 || true

# Force immediate list refresh after scan completes.
BT_JSON="$($CFG/scripts/bt-list.sh)"
eww --config "$CFG" update bt-list="$BT_JSON" >/dev/null 2>&1 || true

if [ "$BT_JSON" = "[]" ]; then
    notify-send "Bluetooth" "Scan complete (no devices found)" -i bluetooth
else
    notify-send "Bluetooth" "Scan complete" -i bluetooth
fi
