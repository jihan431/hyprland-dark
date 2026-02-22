#!/bin/bash

# Directory for recordings
SAVE_DIR="$HOME/Videos/Recordings"
mkdir -p "$SAVE_DIR"

# Check if recording is already active
if pgrep -x "wf-recorder" > /dev/null; then
    # Stop recording
    pkill -INT -x "wf-recorder"
    notify-send "Recording" "Recording stopped and saved to $SAVE_DIR" -i camera-video
else
    # Start recording
    FILENAME="recording_$(date +'%Y-%m-%d_%H-%M-%S').mp4"
    notify-send "Recording" "Recording started..." -i camera-video
    wf-recorder -f "$SAVE_DIR/$FILENAME" &
fi
