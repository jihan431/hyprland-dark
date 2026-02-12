#!/bin/bash

option=$(printf " Shutdown\n Reboot\n󰍃 Logout" | rofi -dmenu -p "Power Menu")

case "$option" in
  " Shutdown")
    shutdown -h +0.5 "Shutdown dalam 30 detik"
    ;;
  " Reboot")
    reboot
    ;;
  "󰍃 Logout")
    hyprctl dispatch exit
    ;;
  *)
    echo "No valid option selected."
    ;;
esac

