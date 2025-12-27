#!/usr/bin/env bash

clear_cmd=$(printf "0\tClear Clipboard History")

result=$((cliphist list && echo "$clear_cmd") | rofi -dmenu -display-columns 2 -p "Clipboard:" -kb-custom-1 "Delete" -kb-remove-char-forward "")

exit_code=$?

if [ -z "$result" ]; then
    exit 0
fi

if [[ "$result" == *"Clear Clipboard History"* ]]; then
    confirm=$(echo -e "No\nYes" | rofi -dmenu -p "Are you sure you want to wipe history?")
    if [ "$confirm" = "Yes" ]; then
        cliphist wipe
    fi
    exit 0
fi

case $exit_code in
    0)
        echo "$result" | cliphist decode | wl-copy
        ;;
    10)
        echo "$result" | cliphist delete
        exec "$0"
        ;;
    *)
        exit 0
        ;;
esac
