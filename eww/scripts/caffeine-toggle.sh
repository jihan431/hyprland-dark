#!/bin/bash
# Toggle caffeine mode via systemd-inhibit.

PID_FILE="/tmp/eww-caffeine.pid"

pid_is_caffeine() {
    local pid="$1"
    [ -n "$pid" ] || return 1
    [ -d "/proc/$pid" ] || return 1

    if [ -r "/proc/$pid/environ" ] && tr '\0' '\n' < "/proc/$pid/environ" | grep -q "^EWW_CAFFEINE=1$"; then
        return 0
    fi

    if [ -r "/proc/$pid/cmdline" ] && tr '\0' ' ' < "/proc/$pid/cmdline" | grep -q "EWW Caffeine"; then
        return 0
    fi

    return 1
}

is_active() {
    [ -f "$PID_FILE" ] || return 1
    local pid
    pid="$(cat "$PID_FILE" 2>/dev/null)"
    [ -n "$pid" ] || return 1
    kill -0 "$pid" 2>/dev/null || return 1
    pid_is_caffeine "$pid"
}

stop_caffeine() {
    local pid
    pid="$(cat "$PID_FILE" 2>/dev/null)"
    if [ -n "$pid" ] && pid_is_caffeine "$pid"; then
        kill "$pid" 2>/dev/null || true
        sleep 0.1
        kill -9 "$pid" 2>/dev/null || true
    fi
    hyprctl dispatch idle-inhibit 0 >/dev/null 2>&1
    rm -f "$PID_FILE"
}

start_caffeine() {
    local pid=""
    rm -f "$PID_FILE"

    if command -v systemd-inhibit >/dev/null 2>&1; then
        EWW_CAFFEINE=1 systemd-inhibit --what=idle:sleep --mode=block --why="EWW Caffeine" \
            bash -c 'while :; do sleep 600; done' >/dev/null 2>&1 &
        pid=$!
        sleep 0.35
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null && pid_is_caffeine "$pid"; then
            echo "$pid" > "$PID_FILE"
            return 0
        fi
    else
        true
    fi

    EWW_CAFFEINE=1 bash -c 'while :; do sleep 600; done' >/dev/null 2>&1 &
    pid=$!
    sleep 0.15
    hyprctl dispatch idle-inhibit 1 >/dev/null 2>&1
    echo "$pid" > "$PID_FILE"
    return 0
}

if is_active; then
    stop_caffeine
    notify-send "Caffeine" "Disabled" -i weather-clear-night
else
    start_caffeine
    if is_active; then
        notify-send "Caffeine" "Enabled (sleep inhibited)" -i weather-clear
    else
        notify-send "Caffeine" "Failed to enable" -i dialog-error
    fi
fi
