#!/bin/bash
result="["
first=1
while IFS=" " read -r _ mac name; do
  [ -z "$mac" ] && continue
  name=$(echo "$name" | sed 's/"/\\"/g')
  conn=$(bluetoothctl info "$mac" 2>/dev/null | grep -c "Connected: yes" || echo 0)
  [ "$first" = "0" ] && result="$result,"
  result="$result{\"name\":\"$name\",\"mac\":\"$mac\",\"connected\":\"$conn\"}"
  first=0
done < <(bluetoothctl devices 2>/dev/null | head -8)
echo "$result]"
