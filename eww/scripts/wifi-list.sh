#!/bin/bash
# Output JSON array of available WiFi networks
# Format: [{"active": bool, "ssid": "...", "signal": int, "security": "WPA2|--"}, ...]

python3 -c "
import subprocess, json, re

result = subprocess.run(
    ['nmcli', '-t', '-f', 'IN-USE,SSID,SIGNAL,SECURITY', 'device', 'wifi', 'list'],
    capture_output=True, text=True
)

networks = []
seen = set()

for line in result.stdout.strip().split('\n'):
    if not line.strip():
        continue
    # nmcli -t escapes ':' in SSID as '\:' — split on unescaped ':'
    parts = re.split(r'(?<!\\\\):', line)
    if len(parts) < 4:
        continue
    active = parts[0] == '*'
    ssid = re.sub(r'\\\\:', ':', parts[1])
    try:
        signal = int(parts[2])
    except ValueError:
        signal = 0
    security = parts[3].strip() if len(parts) > 3 else '--'

    if ssid and ssid not in seen:
        seen.add(ssid)
        networks.append({
            'active': active,
            'ssid': ssid,
            'signal': signal,
            'security': security
        })

networks.sort(key=lambda x: x['signal'], reverse=True)
print(json.dumps(networks))
" 2>/dev/null || echo "[]"
