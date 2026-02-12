#!/usr/bin/env bash

while true; do
  # Ambil workspace list dari hyprctl
  workspaces=$(hyprctl workspaces | grep 'workspace ID' | awk '{print $4}')

  # Format output buat Waybar, misal icon workspace 1-4 atau default icon
  output=""
  for ws in 1 2 3 4; do
    if echo "$workspaces" | grep -qw "$ws"; then
      # Workspace ada, kasih icon aktif (atau beda)
      output+=" "
    else
      # Workspace kosong atau gak ada, kasih icon default (atau kosong)
      output+=" "
    fi
  done

  echo "$output"
  sleep 1
done
