#!/usr/bin/env bash

result=$( (cliphist list && printf "0\tClear Clipboard History") | \
	rofi -dmenu -display-columns 2 -p "Clipboard:" -kb-custom-1 "Delete" -kb-remove-char-forward "")

exit_code=$?

[[ -z "$result" ]] && exit 0

if [[ "$result" == *"Clear Clipboard History"* ]]; then
	confirm=$(echo -e "No\nYes" | rofi -dmenu -p "Are you sure you want to wipe history?")
	[[ "$confirm" = "Yes" ]] && cliphist wipe
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
