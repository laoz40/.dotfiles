#!/usr/bin/env bash

input=$(rofi -dmenu -i -p "Power Menu:" <<-EOF
	  Power Off
	  Reboot
	󰤄  Sleep
	  Lock
EOF
)

case "$input" in
	"  Power Off") poweroff ;;
	"  Reboot") reboot ;;
	"󰤄  Sleep") systemctl suspend ;;
	"  Lock") hyprlock ;;
	*) exit 1 ;;
esac
