#!/usr/bin/env bash

wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

STATE=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)

if [[ $STATE == *"MUTED"* ]]; then
    notify-send -r 1000 -u low "Microphone" "Muted"
else
    notify-send -r 1000 -u low "Microphone" "Active"
fi
