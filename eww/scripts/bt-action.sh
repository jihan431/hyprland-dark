#!/bin/bash
# Handle Bluetooth connect/disconnect robustly across controllers.
CFG="$HOME/dotfiles/eww"
MAC="$1"
NAME="${2:-$1}"

if [ -z "$MAC" ]; then
    exit 1
fi

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

btctl() {
    local addr="$1"
    shift
    if [ -n "$addr" ]; then
        bluetoothctl --controller "$addr" "$@"
    else
        bluetoothctl "$@"
    fi
}

refresh_bt_list() {
    local json
    json="$($CFG/scripts/bt-list.sh)"
    eww --config "$CFG" update bt-list="$json" >/dev/null 2>&1 || true
}

is_connected() {
    local addrs="$1"

    if [ -z "$addrs" ]; then
        bluetoothctl info "$MAC" 2>/dev/null | grep -q "Connected: yes"
        return $?
    fi

    for addr in $addrs; do
        btctl "$addr" info "$MAC" 2>/dev/null | grep -q "Connected: yes" && return 0
    done
    return 1
}

is_paired() {
    local addrs="$1"

    if [ -z "$addrs" ]; then
        bluetoothctl info "$MAC" 2>/dev/null | grep -q "Paired: yes"
        return $?
    fi

    for addr in $addrs; do
        btctl "$addr" info "$MAC" 2>/dev/null | grep -q "Paired: yes" && return 0
    done
    return 1
}

stop_discovery() {
    local addrs="$1"

    for a in $(adapters); do
        busctl --system call org.bluez "/org/bluez/$a" org.bluez.Adapter1 StopDiscovery >/dev/null 2>&1 || true
    done

    for addr in $addrs; do
        btctl "$addr" scan off >/dev/null 2>&1 || true
    done
    bluetoothctl scan off >/dev/null 2>&1 || true
}

ADDRS="$(controller_addrs)"

# Toggle behavior: if already connected, disconnect.
if is_connected "$ADDRS"; then
    notify-send "Bluetooth" "Disconnecting $NAME..." -i bluetooth
    for addr in $ADDRS; do
        btctl "$addr" disconnect "$MAC" >/dev/null 2>&1 || true
    done
    bluetoothctl disconnect "$MAC" >/dev/null 2>&1 || true
    sleep 1

    refresh_bt_list
    if is_connected "$ADDRS"; then
        notify-send "Bluetooth" "Failed to disconnect $NAME" -i bluetooth-error
    else
        notify-send "Bluetooth" "Disconnected from $NAME" -i bluetooth
    fi
    exit 0
fi

notify-send "Bluetooth" "Connecting to $NAME..." -i bluetooth
stop_discovery "$ADDRS"

# Ensure trusted + paired before connect.
if ! is_paired "$ADDRS"; then
    notify-send "Bluetooth" "Pairing with $NAME..." -i bluetooth
    for addr in $ADDRS; do
        btctl "$addr" pair "$MAC" >/dev/null 2>&1 || true
    done
    bluetoothctl pair "$MAC" >/dev/null 2>&1 || true
    sleep 1
fi

for addr in $ADDRS; do
    btctl "$addr" trust "$MAC" >/dev/null 2>&1 || true
done
bluetoothctl trust "$MAC" >/dev/null 2>&1 || true

connected=0
for _ in 1 2 3; do
    for addr in $ADDRS; do
        btctl "$addr" connect "$MAC" >/dev/null 2>&1 || true
    done
    bluetoothctl connect "$MAC" >/dev/null 2>&1 || true

    sleep 1
    if is_connected "$ADDRS"; then
        connected=1
        break
    fi
done

refresh_bt_list

if [ "$connected" -eq 1 ]; then
    notify-send "Bluetooth" "Connected to $NAME" -i bluetooth
else
    notify-send "Bluetooth" "Failed to connect to $NAME" -i bluetooth-error
fi
