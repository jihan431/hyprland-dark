#!/bin/bash
# Return 1 if caffeine inhibitor is active, else 0.

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

if [ ! -f "$PID_FILE" ]; then
    echo 0
    exit 0
fi

PID="$(cat "$PID_FILE" 2>/dev/null)"
if [ -z "$PID" ] || ! kill -0 "$PID" 2>/dev/null; then
    rm -f "$PID_FILE"
    echo 0
    exit 0
fi

if pid_is_caffeine "$PID"; then
    echo 1
    exit 0
fi

rm -f "$PID_FILE"
echo 0
