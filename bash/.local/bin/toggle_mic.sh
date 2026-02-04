#!/usr/bin/env bash

if [[ $1 != "waybar_fetch" ]]; then
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
fi

state=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)

if [[ $state == *"MUTED"* ]]; then
    icon=""
    class="muted"
    tooltip="Microphone Muted"
    [[ $1 != "waybar_fetch" ]] && notify-send -r 1000 -u low "Microphone" "Muted"
else
    icon=""
    class="active"
    tooltip="Microphone Active"
    [[ $1 != "waybar_fetch" ]] && notify-send -r 1000 -u low "Microphone" "Active"
fi

printf '{"text": "%s", "class": "%s", "tooltip": "%s"}\n' "$icon" "$class" "$tooltip"
