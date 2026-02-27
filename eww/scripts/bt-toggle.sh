#!/bin/bash
# Toggle Bluetooth on/off dengan handling "No default controller available"
# Usage: bt-toggle.sh [on|off|toggle]
CFG="$HOME/dotfiles/eww"
MODE="${1:-toggle}"

# Allow yuck to pass current numeric state directly.
# 1 means currently ON -> action should be OFF, 0 means currently OFF -> action should be ON.
case "$MODE" in
    1) MODE="off" ;;
    0) MODE="on" ;;
esac

adapters() {
    for path in /sys/class/bluetooth/hci*; do
        [ -e "$path" ] || continue
        basename "$path"
    done
}

controllers() {
    bluetoothctl list 2>/dev/null | awk '/^Controller / {print $2}'
}

set_power_dbus() {
    local adapter="$1"
    local state="$2" # true|false
    busctl set-property org.bluez "/org/bluez/$adapter" org.bluez.Adapter1 Powered b "$state" >/dev/null 2>&1 || true
}

is_bt_on() {
    "$HOME/dotfiles/eww/scripts/bt-status.sh" | grep -q '^1$'
}

power_on_bt() {
    for adapter in $(adapters); do
        set_power_dbus "$adapter" true
    done
    sleep 0.3
    is_bt_on && return 0

    bluetoothctl power on >/dev/null 2>&1 || true
    sleep 0.3
    is_bt_on && return 0

    for ctl in $(controllers); do
        bluetoothctl select "$ctl" >/dev/null 2>&1 || true
        bluetoothctl power on >/dev/null 2>&1 || true
        sleep 0.2
        is_bt_on && return 0
    done

    is_bt_on
}

power_off_bt() {
    for adapter in $(adapters); do
        set_power_dbus "$adapter" false
    done
    sleep 0.3
    is_bt_on || return 0

    bluetoothctl power off >/dev/null 2>&1 || true
    sleep 0.3
    is_bt_on || return 0

    for ctl in $(controllers); do
        bluetoothctl select "$ctl" >/dev/null 2>&1 || true
        bluetoothctl power off >/dev/null 2>&1 || true
        sleep 0.2
    done
    is_bt_on || return 0

    ! is_bt_on
}

set_bt_state_var() {
    if is_bt_on; then
        eww --config "$CFG" update bt-enabled=1
    else
        eww --config "$CFG" update bt-enabled=0
    fi
}

case "$MODE" in
    on)
        if [ -z "$(controllers)" ] && [ -z "$(adapters)" ]; then
            notify-send "Bluetooth" "No controller detected" -i bluetooth
        fi
        power_on_bt >/dev/null 2>&1 || true
        ;;
    off)
        power_off_bt >/dev/null 2>&1 || true
        ;;
    *)
        if is_bt_on; then
            power_off_bt >/dev/null 2>&1 || true
        else
            if [ -z "$(controllers)" ] && [ -z "$(adapters)" ]; then
                notify-send "Bluetooth" "No controller detected" -i bluetooth
            fi
            power_on_bt >/dev/null 2>&1 || true
        fi
        ;;
esac

set_bt_state_var
