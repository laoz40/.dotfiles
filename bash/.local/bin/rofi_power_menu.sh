#!/usr/bin/env bash

chosen=$(printf "  Power Off\n  Reboot\n󰤄  Sleep\n  Lock" | rofi -dmenu -i -p "Power Menu:" -theme-str '@import "power.rasi"')

case "$chosen" in
	"  Power Off") poweroff ;;
	"  Reboot") reboot ;;
	"󰤄  Sleep") systemctl suspend ;;
	"  Lock") hyprlock ;;
	*) exit 1 ;;
esac
