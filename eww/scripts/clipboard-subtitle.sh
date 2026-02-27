#!/bin/bash
# Return subtitle text for clipboard module.

if ! command -v cliphist >/dev/null 2>&1; then
    echo "Unavailable"
    exit 0
fi

COUNT="$(cliphist list 2>/dev/null | wc -l)"
COUNT="${COUNT//[[:space:]]/}"
[ -n "$COUNT" ] || COUNT=0

if [ "$COUNT" -gt 0 ] 2>/dev/null; then
    echo "$COUNT items"
else
    echo "Empty"
fi
