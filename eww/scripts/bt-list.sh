#!/bin/bash
# Output JSON array of all Bluetooth devices (paired + discovered)
# Format: [{"mac": "...", "name": "...", "connected": bool}, ...]

python3 -c "
import subprocess, json

def get_devices():
    try:
        # Get all known/discovered devices
        proc = subprocess.run(['bluetoothctl', 'devices'], capture_output=True, text=True)
        device_lines = proc.stdout.strip().split('\n')
        
        # Get currently connected devices
        proc_conn = subprocess.run(['bluetoothctl', 'devices', 'Paired'], capture_output=True, text=True)
        # We also need to check actual connection status since 'Paired' != 'Connected'
        # A more reliable way to get connected devices is parsing 'info' for each or using 'paired-devices'
        # but for speed, we'll use a single call to get info of all devices if possible.
        # However, bluetoothctl doesn't support a single call for all info.
        # Let's use 'bluetoothctl info' only for devices that might be connected.
        
        devices = []
        for line in device_lines:
            if not line.strip(): continue
            parts = line.split(' ', 2)
            if len(parts) < 3: continue
            
            mac = parts[1]
            name = parts[2].strip()
            
            # Check for generic names or empty names
            if not name or name.startswith('Device '):
                # Optionally skip or keep? Let's keep for now but use MAC as fallback
                name = name or mac

            devices.append({'mac': mac, 'name': name, 'connected': False})
            
        # Update connection status for all devices in one go if possible?
        # bluetoothctl doesn't have a 'connected-devices' command that lists just MACs easily.
        # Let's use a faster way to check connectivity:
        # 'bluetoothctl info' is relatively slow. We'll only check devices that are 'paired'
        # to see if they are actually connected.
        
        for dev in devices:
            # We skip info check for very fast listing, but user wants to see 'Connected' state.
            # Let's only check devices that appear in 'paired-devices' or just check all if N is small.
            # To be safe and fast, let's just check the first 10 devices or those that were connected before.
            # Actually, let's just do it for all but capture errors.
            try:
                info = subprocess.run(['bluetoothctl', 'info', dev['mac']], capture_output=True, text=True, timeout=1)
                dev['connected'] = 'Connected: yes' in info.stdout
            except:
                pass
                
        return devices
    except Exception as e:
        return []

print(json.dumps(get_devices()))
" 2>/dev/null || echo "[]"
