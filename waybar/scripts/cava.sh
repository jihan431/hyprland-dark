#!/usr/bin/env bash

set -u

readonly BARS="${CAVA_BARS:-12}"
readonly MAX_LEVEL="${CAVA_MAX_LEVEL:-8}"
readonly FALL_STEP="${CAVA_FALL_STEP:-1}"
readonly NOISE_GATE="${CAVA_NOISE_GATE:-1}"
readonly PLAYERCTL_POLL_EVERY="${CAVA_PLAYERCTL_POLL_EVERY:-12}"
readonly LEVELS=" ▁▂▃▄▅▆▇█"

if ! command -v cava >/dev/null 2>&1; then
    exit 1
fi

playerctl_available=0
if command -v playerctl >/dev/null 2>&1; then
    playerctl_available=1
fi

config_file="$(mktemp /tmp/waybar_cava.XXXXXX)"
trap 'rm -f "$config_file"' EXIT

cat >"$config_file" <<EOF
[general]
bars = ${BARS}
framerate = 60
sensitivity = 100

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = ${MAX_LEVEL}
EOF

declare -a previous_levels
for ((i = 0; i < BARS; i++)); do
    previous_levels[i]=0
done

frame_counter=0
media_playing=0

update_media_state() {
    if (( playerctl_available == 0 )); then
        return
    fi

    if (( frame_counter % PLAYERCTL_POLL_EVERY != 0 )); then
        return
    fi

    status="$(playerctl status 2>/dev/null | head -n1 || true)"
    if [[ "$status" == "Playing" ]]; then
        media_playing=1
    else
        media_playing=0
    fi
}

render_frame() {
    local -a values=("$@")
    local output=""
    local silent=1
    local class="idle"
    local text=""

    for ((i = 0; i < BARS; i++)); do
        level="${values[i]:-0}"

        if [[ ! "$level" =~ ^[0-9]+$ ]]; then
            level=0
        fi

        if (( level > MAX_LEVEL )); then
            level=MAX_LEVEL
        fi

        # Cut tiny fluctuations so idle state looks clean.
        if (( level <= NOISE_GATE )); then
            level=0
        fi

        # Smooth the fall so bars don't drop too sharply.
        if (( level < previous_levels[i] )); then
            next_level=$((previous_levels[i] - FALL_STEP))
            if (( next_level > level )); then
                level=$next_level
            fi
        fi

        if (( level < 0 )); then
            level=0
        fi

        previous_levels[i]=$level

        if (( level > 0 )); then
            silent=0
        fi

        output+="${LEVELS:level:1}"
    done

    if (( silent == 0 )); then
        text="$output"
    fi

    if (( playerctl_available == 1 )); then
        if (( media_playing == 1 )); then
            class="active"
        fi
    elif (( silent == 0 )); then
        class="active"
    fi

    printf '{"text":"%s","class":"%s"}\n' "$text" "$class"
}

cava -p "$config_file" | while IFS= read -r line; do
    ((frame_counter++))
    update_media_state
    IFS=';' read -r -a values <<<"$line"
    render_frame "${values[@]}"
done
