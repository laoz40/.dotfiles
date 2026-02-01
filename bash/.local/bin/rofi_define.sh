#!/usr/bin/env bash

# https://github.com/BreadOnPenguins/scripts/blob/master/shortcuts-menus/define

word=$(echo "Use Clipboard" | rofi -dmenu -no-fixed-num-lines \
  -theme-str 'window {width: 20%; }'\
  -p "Define:"
)

[[ "$word" == "Use Clipboard" ]] && word=$(xclip -o -selection primary 2>/dev/null || wl-paste 2>/dev/null)

[[ -z "$word" ]] && exit 0
[[ "$word" =~ [\/] ]] && notify-send -u critical -t 3000 "Invalid input." && exit 0

query=$(curl -s --connect-timeout 5 --max-time 10 "https://api.dictionaryapi.dev/api/v2/entries/en_US/$word")

[ $? -ne 0 ] && notify-send -u critical -t 3000 "Invalid input." && exit 0
[[ "$query" == *"No Definitions Found"* ]] && notify-send -u critical -t 3000 "Invalid word." && exit 0

# Show first definition for each part of speech (thanks @morgengabe1 on youtube)
def=$(echo "$query" | jq -r '.[0].meanings[] | "\(.partOfSpeech): \(.definitions[0].definition)\n"')
notify-send -t 20000 "$word" "$def"
