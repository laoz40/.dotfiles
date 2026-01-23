#!/bin/bash

EXTERNAL_MONITOR="DP-3"
INTERNAL_MONITOR="eDP-1"

if hyprctl monitors | grep -q "$EXTERNAL_MONITOR"; then
    echo "\$MONITOR = $EXTERNAL_MONITOR" > ~/.config/hypr/set_monitor.conf
else
    echo "\$MONITOR = $INTERNAL_MONITOR" > ~/.config/hypr/set_monitor.conf
fi

hyprctl reload
