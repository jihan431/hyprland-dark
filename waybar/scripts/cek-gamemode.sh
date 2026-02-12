#!/bin/bash
FLAGFILE="$HOME/.gamemode_active"

if [ -f "$FLAGFILE" ]; then
    echo "🎮"
else
    echo "💻"
fi
