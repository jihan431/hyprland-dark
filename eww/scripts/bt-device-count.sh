#!/bin/bash
# Return bluetooth device count from latest cached bt-list output.

python3 - <<'PY'
import json

cache = '/tmp/eww-bt-list.json'
count = 0

try:
    with open(cache, 'r', encoding='utf-8') as f:
        data = json.load(f)
    if isinstance(data, list):
        count = len(data)
except Exception:
    count = 0

print(count)
PY
