#!/bin/bash
# Output clipboard history as JSON for EWW.
# Format: [{"id":"<cliphist id>","text":"..."}]

MAX_ITEMS="${1:-10}"

if ! command -v cliphist >/dev/null 2>&1; then
    echo "[]"
    exit 0
fi

python3 - "$MAX_ITEMS" <<'PY'
import json
import subprocess
import sys

try:
    limit = max(1, int(sys.argv[1]))
except Exception:
    limit = 10

try:
    output = subprocess.run(
        ["cliphist", "list"],
        capture_output=True,
        text=True,
        timeout=2,
    ).stdout
except Exception:
    print("[]")
    raise SystemExit

items = []
for line in output.splitlines():
    if not line.strip():
        continue

    if "\t" in line:
        item_id, preview = line.split("\t", 1)
    else:
        item_id, preview = line, line
    item_id = item_id.strip()
    if not item_id:
        continue

    preview = " ".join(preview.split())
    icon = "󰅌"
    if "[[ binary data" in preview:
        icon = "󰋩"
        # Try to extract format/size if possible
        # e.g. [[ binary data 237 KiB png 1920x1080 ]]
        parts = preview.replace("[[", "").replace("]]", "").split()
        if len(parts) >= 5:
             # parts = ['binary', 'data', '237', 'KiB', 'png', ...]
             ext = parts[4].upper()
             size = f"{parts[2]} {parts[3]}"
             preview = f"Photo ({ext}, {size})"
        else:
             preview = "Photo/Image"
    
    if not preview:
        preview = "[empty]"
    elif len(preview) > 72:
        preview = preview[:72] + "..."

    items.append(
        {
            "id": item_id,
            "text": preview,
            "icon": icon,
        }
    )
    if len(items) >= limit:
        break

print(json.dumps(items))
PY
