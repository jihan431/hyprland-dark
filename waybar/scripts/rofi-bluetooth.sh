#!/bin/bash

# rofi-bluetooth.sh
# Managing Bluetooth via Rofi

# Constants
THEME="/home/lyon/dotfiles/rofi/bluetooth.rasi"

# Functions
power_on() {
    bluetoothctl power on
}

power_off() {
    bluetoothctl power off
}

# Get status
get_status() {
    if [ $(bluetoothctl show | grep "Powered: yes" | wc -l) -eq 1 ]; then
        echo "ON"
    else
        echo "OFF"
    fi
}

STATUS=$(get_status)

# Prepare lists
declare -a ACTIONS
declare -a MACS
declare -a NAMES
INDEX=0
OPTIONS=""

append_option() {
    local item="$1"
    if [ -n "$OPTIONS" ]; then
        OPTIONS+="\n"
    fi
    OPTIONS+="$item"
}

# 1. Add Control Buttons
# We use a special prefix in ACTIONS array to identify them
if [ "$STATUS" == "ON" ]; then
    # Button 1: Turn Off
    append_option "Turn Off"
    ACTIONS[$INDEX]="POWER_OFF"
    ((INDEX++))
    
    # Button 2: Rescan
    append_option "Rescan"
    ACTIONS[$INDEX]="RESCAN"
    ((INDEX++))
else
    # Button 1: Turn On
    append_option "Turn On"
    ACTIONS[$INDEX]="POWER_ON"
    ((INDEX++))
    
    # Button 2: Exit
    append_option "Exit"
    ACTIONS[$INDEX]="EXIT"
    ((INDEX++))
    
    # In OFF state, we just show these buttons
    printf '%b' "$OPTIONS" | rofi -dmenu -i -p "Bluetooth" -theme "$THEME" -markup-rows -format i -u 0,1 > /tmp/rofi_bt_selection
    
    # Handle Selection (OFF State)
    SELECTION=$(cat /tmp/rofi_bt_selection)
    rm /tmp/rofi_bt_selection
    
    if [ -z "$SELECTION" ]; then exit 0; fi
    
    selected_action="${ACTIONS[$SELECTION]}"
    case "$selected_action" in
        "POWER_ON") power_on ;;
        "EXIT") exit 0 ;;
    esac
    exit 0
fi

# 2. Add Devices (Only if ON)

# Check if scanning
if ! pgrep -f "bluetoothctl scan on" > /dev/null; then
    # Auto scan for 3 sec if not scanning
    bluetoothctl scan on > /dev/null 2>&1 &
    sleep 0.5
fi

# Get formatted device list
# Format: "Device <MAC> <Name>"
# parsing `bluetoothctl devices`
# We iterate line by line
while read -r line; do
    # Ignore empty/noise lines and only parse device rows.
    [[ -z "${line// }" ]] && continue
    [[ "$line" != Device\ * ]] && continue

    MAC=$(echo "$line" | cut -d ' ' -f 2)
    NAME=$(echo "$line" | cut -d ' ' -f 3-)
    
    # Skip if MAC is missing
    if [ -z "$MAC" ]; then continue; fi
    # Fallback label when bluetoothctl does not provide a name.
    if [ -z "${NAME// }" ]; then NAME="$MAC"; fi
    
    # Check info
    INFO=$(bluetoothctl info "$MAC")
    CONNECTED=$(echo "$INFO" | grep "Connected: yes")
    TRUSTED=$(echo "$INFO" | grep "Trusted: yes")
    ICON=""
    
    # Visual markers
    STATUS_MARK=""
    if [ -n "$CONNECTED" ]; then
        STATUS_MARK="<span color='#a6da95'><b>(Connected)</b></span>"
        ICON="󰂱"
    elif [ -n "$TRUSTED" ]; then
         STATUS_MARK="<span size='small' color='#6c6c8c'>(Trusted)</span>"
    fi
    
    # Display Format: Icon   Name   Status
    DISPLAY="$ICON   <b>$NAME</b>   $STATUS_MARK <span size='small' color='#6c6c8c'>$MAC</span>"
    
    append_option "$DISPLAY"
    ACTIONS[$INDEX]="DEVICE"
    MACS[$INDEX]="$MAC"
    NAMES[$INDEX]="$NAME"
    ((INDEX++))
    
done < <(bluetoothctl devices 2>/dev/null)

# Show Menu
# -u 0,1 marks the first two items (buttons) as urgent
CHOSEN_INDEX=$(printf '%b' "$OPTIONS" | rofi -dmenu -i -p "Bluetooth" -theme "$THEME" -markup-rows -format i -u 0,1)

if [ -z "$CHOSEN_INDEX" ]; then exit 0; fi

ACTION="${ACTIONS[$CHOSEN_INDEX]}"

case "$ACTION" in
    "POWER_OFF")
        power_off
        ;;
    "RESCAN")
        killall bluetoothctl
        bluetoothctl scan on > /dev/null 2>&1 &
        notify-send "Bluetooth" "Rescanning..."
        ;;
    "DEVICE")
        MAC="${MACS[$CHOSEN_INDEX]}"
        DEV_NAME="${NAMES[$CHOSEN_INDEX]}"
        
        # Submenu for device action
        ACT=$(echo -e "Connect\nDisconnect\nPair\nTrust\nRemove\nCancel" | rofi -dmenu -i -p "$DEV_NAME" -theme "$THEME")
        
        case "$ACT" in
            "Connect")
                notify-send "Bluetooth" "Connecting to $DEV_NAME..."
                bluetoothctl connect "$MAC"
                ;;
            "Disconnect")
                bluetoothctl disconnect "$MAC"
                ;;
            "Pair")
                bluetoothctl pair "$MAC"
                ;;
            "Trust")
                bluetoothctl trust "$MAC"
                ;;
            "Remove")
                bluetoothctl remove "$MAC"
                ;;
        esac
        ;;
esac
