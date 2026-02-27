#!/bin/bash
# Return number of items in cliphist.

if ! command -v cliphist >/dev/null 2>&1; then
    echo 0
    exit 0
fi

COUNT="$(cliphist list 2>/dev/null | wc -l)"
COUNT="${COUNT//[[:space:]]/}"

if [ -z "$COUNT" ]; then
    COUNT=0
fi

echo "$COUNT"
