#!/usr/bin/env bash

set -u

# Group processes by a useful application name. Electron helpers are folded into
# their parent application instead of appearing as a dozen identical entries.
declare -A grouped

while read -r pid comm args; do
	[[ $pid == $$ || -z ${pid:-} ]] && continue

	label=$comm
	case "$args" in
		*vesktop*/resources/app.asar*) label=Vesktop ;;
		*/obsidian/app.asar*) label=Obsidian ;;
		*'/steam.sh '*) label=Steam ;;
		*'flatpak run '*)
			label=${args#*flatpak run }
			label=${label%% *}
			label=${label##*.}
			;;
	esac

	# Helper processes are killed with their main app and should not get entries.
	[[ $args == *' --type='* || $args == *'/rofi-process-killer.sh'* ]] && continue

	case "$label" in
		systemd|'(sd-pam)'|Hyprland|start-hyprland|dbus-broker|dbus-broker-lau|Xwayland|rofi|ps)
			continue
			;;
	esac

	grouped["$label"]+=" $pid"
done < <(ps -u "$UID" -o pid=,comm=,args=)

mapfile -t labels < <(printf '%s\n' "${!grouped[@]}" | sort -f)
((${#labels[@]})) || exit 0

menu=()
for label in "${labels[@]}"; do
	read -ra pids <<< "${grouped[$label]}"
	menu+=("$label (${#pids[@]} process$([[ ${#pids[@]} == 1 ]] || printf 'es'))")
done

index=$(printf '%s\n' "${menu[@]}" | rofi -dmenu -i -format i -p 'Stop application:') || exit 0
[[ $index =~ ^[0-9]+$ ]] || exit 0

label=${labels[$index]}
read -ra roots <<< "${grouped[$label]}"

# Capture descendants before asking the main processes to exit.
targets=("${roots[@]}")
for ((i = 0; i < ${#targets[@]}; i++)); do
	while read -r child; do
		[[ -n $child ]] && targets+=("$child")
	done < <(pgrep -P "${targets[$i]}" 2>/dev/null || true)
done

kill -TERM "${targets[@]}" 2>/dev/null || true
sleep 2

survivors=()
for pid in "${targets[@]}"; do
	kill -0 "$pid" 2>/dev/null && survivors+=("$pid")
done
((${#survivors[@]})) && kill -KILL "${survivors[@]}" 2>/dev/null || true
