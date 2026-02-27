#!/bin/bash
# Output JSON array of all Bluetooth devices (paired + discovered)
# Format: [{"mac": "...", "name": "...", "connected": bool}, ...]

python3 - <<'PY'
import json
import os
import re
import subprocess

CACHE_FILE = "/tmp/eww-bt-list.json"


def run(args, timeout=3):
    try:
        return subprocess.run(
            args,
            capture_output=True,
            text=True,
            timeout=timeout,
        ).stdout
    except Exception:
        return ""


def parse_busctl_value(output):
    output = output.strip()
    if not output:
        return None

    parts = output.split(" ", 1)
    if len(parts) != 2:
        return None

    vtype, raw = parts[0], parts[1].strip()

    if vtype == "b":
        return raw == "true"

    if vtype in {"y", "n", "q", "i", "u", "x", "t"}:
        try:
            return int(raw.split()[0])
        except Exception:
            return None

    if vtype == "s":
        if len(raw) >= 2 and raw[0] == '"' and raw[-1] == '"':
            inner = raw[1:-1]
            try:
                return bytes(inner, "utf-8").decode("unicode_escape")
            except Exception:
                return inner
        return raw.strip('"')

    return raw


def get_device_prop(path, prop):
    out = run(
        [
            "busctl",
            "get-property",
            "org.bluez",
            path,
            "org.bluez.Device1",
            prop,
        ],
        timeout=1.5,
    )
    return parse_busctl_value(out)


def parse_addr_from_path(path):
    if "/dev_" not in path:
        return ""
    return path.rsplit("/dev_", 1)[1].replace("_", ":")


def list_devices_dbus():
    devices = []
    seen_paths = set()
    # Compatibility: some busctl versions only support `tree SERVICE`.
    tree = run(["busctl", "--system", "tree", "org.bluez"])
    if not tree:
        tree = run(["busctl", "tree", "org.bluez"])

    for match in re.finditer(r"/org/bluez/hci\d+/dev_[0-9A-F_]+", tree):
        dev_path = match.group(0)
        if dev_path in seen_paths:
            continue
        seen_paths.add(dev_path)

        mac = get_device_prop(dev_path, "Address") or parse_addr_from_path(dev_path)
        alias = get_device_prop(dev_path, "Alias")
        name = get_device_prop(dev_path, "Name")
        connected = bool(get_device_prop(dev_path, "Connected"))
        rssi = get_device_prop(dev_path, "RSSI")

        if not mac:
            continue

        devices.append(
            {
                "mac": mac,
                "name": alias or name or mac,
                "connected": connected,
                "_rssi": rssi if isinstance(rssi, int) else -999,
            }
        )

    devices.sort(key=lambda d: (not d["connected"], -d["_rssi"], d["name"].lower()))
    for d in devices:
        d.pop("_rssi", None)
    return devices


def list_devices_bluetoothctl():
    addrs = []
    for sys_path in sorted(os.listdir("/sys/class/bluetooth")) if os.path.isdir("/sys/class/bluetooth") else []:
        if not re.match(r"^hci\d+$", sys_path):
            continue
        addr_file = f"/sys/class/bluetooth/{sys_path}/address"
        try:
            with open(addr_file, "r", encoding="utf-8") as f:
                addrs.append(f.read().strip())
        except Exception:
            pass

    if not addrs:
        addrs = [None]

    all_text = []
    connected_text = []
    for addr in addrs:
        base = ["bluetoothctl"]
        if addr:
            base += ["--controller", addr]

        all_text.append(run(base + ["devices"]))
        all_text.append(run(base + ["devices", "Paired"]))
        all_text.append(run(base + ["paired-devices"]))
        connected_text.append(run(base + ["devices", "Connected"]))

    all_lines = ("\n".join(all_text)).splitlines()
    connected_lines = ("\n".join(connected_text)).splitlines()

    connected_macs = set()
    for line in connected_lines:
        parts = line.split(" ", 2)
        if len(parts) >= 2:
            connected_macs.add(parts[1])

    devices = []
    seen = set()
    controllers_for_info = [addr for addr in addrs if addr]

    def get_rssi(mac):
        info_texts = []
        if controllers_for_info:
            for ctl_addr in controllers_for_info:
                info_texts.append(run(["bluetoothctl", "--controller", ctl_addr, "info", mac], timeout=1.2))
        else:
            info_texts.append(run(["bluetoothctl", "info", mac], timeout=1.2))

        for txt in info_texts:
            m = re.search(r"RSSI:\s*(-?\d+)", txt or "")
            if m:
                try:
                    return int(m.group(1))
                except Exception:
                    return -999
        return -999

    for line in all_lines:
        parts = line.split()
        if len(parts) < 2 or parts[0] != "Device":
            continue

        mac = parts[1].strip()
        name = " ".join(parts[2:]).strip() or mac
        if mac in seen:
            continue
        seen.add(mac)

        devices.append(
            {
                "mac": mac,
                "name": name,
                "connected": mac in connected_macs,
                "_rssi": get_rssi(mac),
            }
        )

    devices.sort(key=lambda d: (not d["connected"], -d["_rssi"], d["name"].lower()))
    for d in devices:
        d.pop("_rssi", None)
    return devices


def write_cache(devices):
    try:
        with open(CACHE_FILE, "w", encoding="utf-8") as f:
            json.dump(devices, f)
    except Exception:
        pass


devices = list_devices_dbus()
if not devices:
    devices = list_devices_bluetoothctl()
write_cache(devices)

print(json.dumps(devices))
PY
