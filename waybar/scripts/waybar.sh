#!/bin/bash

killall -9 waybar
hyprctl reload
waybar &
