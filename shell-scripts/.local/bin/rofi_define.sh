#!/usr/bin/env bash

# https://github.com/BreadOnPenguins/scripts/blob/master/shortcuts-menus/define

word=$(echo "Use Clipboard" | rofi -dmenu -no-fixed-num-lines \
  -theme-str 'window {width: 20%; }'\
  -p "Define:"
)

[[ "$word" == "Use Clipboard" ]] && word=$(xclip -o -selection primary 2>/dev/null || wl-paste 2>/dev/null)

[[ -z "$word" ]] && exit 0
[[ "$word" =~ [\/] ]] && notify-send -u critical -t 3000 "Invalid input." && exit 0

# Show first definition for each part of speech (thanks @morgengabe1 on youtube)

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# Query both sources in parallel and take the first usable answer.
# Primary: the Free Dictionary API (dictionaryapi.dev)
# Fallback: freedictionaryapi.com (Wiktionary data)
# Each curl writes its exit status to a .status file when it finishes,
# which doubles as the "this request is done" signal.
(
  curl -s --connect-timeout 2 --max-time 5 \
    "https://api.dictionaryapi.dev/api/v2/entries/en_US/$word" \
    >"$tmpdir/primary.out" 2>/dev/null
  echo $? >"$tmpdir/primary.status"
) &
p1=$!
(
  curl -s --connect-timeout 2 --max-time 5 \
    "https://freedictionaryapi.com/api/v1/entries/en/$word" \
    >"$tmpdir/fallback.out" 2>/dev/null
  echo $? >"$tmpdir/fallback.status"
) &
p2=$!

def=""

check_primary() {
  [ -f "$tmpdir/primary.status" ] || return 1
  [ "$(cat "$tmpdir/primary.status")" -eq 0 ] || return 1
  [[ "$(<"$tmpdir/primary.out")" != *"No Definitions Found"* ]] || return 1
  def=$(jq -r '.[0].meanings[] | "\(.partOfSpeech): \(.definitions[0].definition)\n"' "$tmpdir/primary.out")
}

check_fallback() {
  [ -f "$tmpdir/fallback.status" ] || return 1
  [ "$(cat "$tmpdir/fallback.status")" -eq 0 ] || return 1
  [ "$(jq -r '.entries | length' "$tmpdir/fallback.out" 2>/dev/null)" -gt 0 ] || return 1
  def=$(jq -r '.entries[] | "\(.partOfSpeech): \(.senses[0].definition)\n"' "$tmpdir/fallback.out")
}

# Return as soon as one source answers with a usable definition.
while true; do
  check_primary && break
  check_fallback && break
  [ -f "$tmpdir/primary.status" ] && [ -f "$tmpdir/fallback.status" ] && break
  wait -n 2>/dev/null
done

# Kill whichever request is still hanging around.
kill "$p1" "$p2" 2>/dev/null

if [[ -z "$def" ]]; then
  notify-send -u critical -t 3000 "No definition found." "Both dictionary sources failed or don't know the word."
  exit 0
fi

notify-send -t 20000 "$word" "$def"