#!/bin/bash
# Return 1 if any bluetooth controller is powered on, else 0.

adapters() {
    for path in /sys/class/bluetooth/hci*; do
        [ -e "$path" ] || continue
        basename "$path"
    done
}

is_powered_dbus() {
    local adapter="$1"
    busctl get-property org.bluez "/org/bluez/$adapter" org.bluez.Adapter1 Powered 2>/dev/null \
        | grep -q "true"
}

controllers=$(bluetoothctl list 2>/dev/null | awk '/^Controller / {print $2}')

for ctl in $controllers; do
    if bluetoothctl show "$ctl" 2>/dev/null | grep -q "Powered: yes"; then
        echo 1
        exit 0
    fi
done

for adapter in $(adapters); do
    if is_powered_dbus "$adapter"; then
        echo 1
        exit 0
    fi
done

echo 0
