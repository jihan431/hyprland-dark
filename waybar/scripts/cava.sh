#!/usr/bin/env bash

set -u

readonly BARS="${CAVA_BARS:-12}"
readonly MAX_LEVEL="${CAVA_MAX_LEVEL:-8}"
readonly FALL_STEP="${CAVA_FALL_STEP:-1}"
readonly NOISE_GATE="${CAVA_NOISE_GATE:-0}"
readonly MIN_LEVEL_WHEN_PLAYING="${CAVA_MIN_LEVEL_WHEN_PLAYING:-1}"
readonly PLAYERCTL_POLL_EVERY="${CAVA_PLAYERCTL_POLL_EVERY:-12}"
readonly LEVELS=" ▁▂▃▄▅▆▇█"

command -v cava >/dev/null 2>&1 || exit 1

playerctl_available=0
command -v playerctl >/dev/null 2>&1 && playerctl_available=1

config_file="$(mktemp /tmp/waybar_cava.XXXXXX)"
trap 'rm -f "$config_file"; pkill -P $$ cava 2>/dev/null' EXIT

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

is_playing() {
    if (( playerctl_available == 0 )); then
        return 0
    fi
    playerctl --all-players status 2>/dev/null | grep -q Playing
}

update_media_state() {
    if (( playerctl_available == 0 )); then
        media_playing=1
        return
    fi

    if (( frame_counter % PLAYERCTL_POLL_EVERY != 0 )); then
        return
    fi

    if is_playing; then
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

        [[ "$level" =~ ^[0-9]+$ ]] || level=0
        (( level > MAX_LEVEL )) && level=$MAX_LEVEL
        (( level <= NOISE_GATE )) && level=0

        if (( level < previous_levels[i] )); then
            next_level=$((previous_levels[i] - FALL_STEP))
            (( next_level > level )) && level=$next_level
        fi

        (( level < 0 )) && level=0

        if (( media_playing == 1 )) && (( level == 0 )) && (( MIN_LEVEL_WHEN_PLAYING > 0 )); then
            level=$MIN_LEVEL_WHEN_PLAYING
        fi

        previous_levels[i]=$level
        (( level > 0 )) && silent=0
        output+="${LEVELS:level:1}"
    done

    (( silent == 0 )) && text="$output"
    (( media_playing == 1 )) && class="active"

    printf '{"text":"%s","class":"%s"}\n' "$text" "$class"
}

while true; do
    if ! is_playing; then
        printf '{"text":"","class":"idle"}\n'
        sleep 2
        continue
    fi

    cava -p "$config_file" | while IFS= read -r line; do
        ((frame_counter++))
        update_media_state

        if ! is_playing; then
            pkill -P $$ cava 2>/dev/null
            break
        fi

        IFS=';' read -r -a values <<<"$line"
        render_frame "${values[@]}"
    done
done
