#!/usr/bin/env bash

timer_file=/tmp/waybar_timer
timer_paused=/tmp/timer_paused

# waybar get timer
if [[ $1 == "get" ]]; then
	if [[ -f $timer_file ]]; then
		content=$(cat $timer_file)
		# printf json for waybar
		if [[ -f "$timer_paused" ]]; then
			printf '{"text": "%s", "alt": "paused", "class": "paused"}\n' "$content"
		else
			printf '{"text": "%s", "alt": "active", "class": "active"}\n' "$content"
		fi
	else
		echo '{"text": "", "class": "stopped"}'
	fi
	exit 0
fi

# waybar pause/resume on-click
if [[ $1 == "toggle" ]]; then
	if [[ -f $timer_file ]]; then
		if [[ -f $timer_paused ]]; then
			rm "$timer_paused"
		else
			touch "$timer_paused"
		fi
	fi
	exit 0
fi

start_timer() {
	local duration_seconds=$(awk "BEGIN {print int($1 * 60)}")
	local current_time=$(date +%s)
	local end_time=$(( current_time + duration_seconds ))

	touch $timer_file

	while [[ -f $timer_file ]]; do
		local current_time=$(date +%s)
		local remaining_time=$(( end_time - current_time ))

		if [[ -f $timer_paused ]]; then
			# Add a second to paused time each second to maintain duration
			((end_time++))
		else
			if [ $remaining_time -le 0 ]; then
				break
			fi
		fi

		local formatted_time=$(printf "%02d:%02d" $((remaining_time/60)) $((remaining_time%60)))
		echo $formatted_time > $timer_file
		sleep 1
	done

	if [[ -f $timer_file ]]; then
		echo "Done" > $timer_file
		notify-send "Time is up!" "Go do the thing you were supposed to do." -i alarm-clock -u critical
		sleep 10
		rm $timer_file
	fi
}

pause_option="Pause"
if [[ -f $timer_paused ]]; then
	pause_option="Resume"
else
	pause_option="Pause"
fi

# NOTE: Auto selects from results if part of input matches string, should type m after for custom time
input=$(rofi -dmenu -p "Set Timer:" <<EOF
25 min
5 min
$pause_option
Cancel Timer
EOF
)

if [[ $input == $pause_option ]]; then
	if [[ -f $timer_paused ]]; then
		rm $timer_paused
		notify-send "Timer Resumed" -i alarm-clock -u normal
	else
		touch $timer_paused
		notify-send "Timer Paused" -i alarm-clock -u normal
	fi
	exit 0
elif [[ $input == "Cancel Timer" ]]; then
	rm $timer_file
	notify-send "Timer Cancelled" -i alarm-clock -u normal
	exit 0
# If input is numbers followed by space min/m (optional)
elif [[ $input =~ ^([0-9]*\.?[0-9]+)([[:space:]?]*min|m)?$ ]]; then
	rm $timer_paused
	minutes=${BASH_REMATCH[1]}
	start_timer $minutes
	exit 0
else
	exit 1
fi
