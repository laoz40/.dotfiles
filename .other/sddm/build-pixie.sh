#!/usr/bin/env bash
set -euo pipefail

if [[ $# != 1 || ! -d $1 || -n $(ls -A -- "$1") ]]; then
    printf 'Usage: %s EMPTY_OUTPUT_DIRECTORY\n' "$0" >&2
    exit 2
fi

here=$(cd -- "$(dirname -- "$0")" && pwd)
wallpapers="$here/../../wallpapers/Pictures/Wallpapers"
upstream=/usr/share/sddm/themes/pixie
output=$1

cp -R -- "$upstream/." "$output/"
patch --batch --forward --fuzz=0 -d "$output" -p1 < "$here/pixie.patch"
install -m 644 -- "$here/theme.conf.user" "$output/theme.conf.user"
install -m 644 -- "$wallpapers/burning-car.jpg" "$wallpapers/spiderverse.png" "$output/assets/"
