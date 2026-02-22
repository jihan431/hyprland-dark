#!/bin/bash
nmcli -t -f SSID,SIGNAL,ACTIVE dev wifi list 2>/dev/null \
  | grep -v "^:" \
  | awk -F: '
    BEGIN { print "[" }
    seen[$1]++ { next }
    NR > 1 && printed > 0 { printf "," }
    $1 != "" {
      active = ($3 == "yes") ? "yes" : "no"
      gsub(/"/, "\\\"", $1)
      printf "{\"ssid\":\"%s\",\"signal\":\"%s\",\"active\":\"%s\"}", $1, $2, active
      printed++
    }
    END { print "]" }
  '
