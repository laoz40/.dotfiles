#!/usr/bin/env bash

timer_file=/tmp/waybar_timer
timer_paused=/tmp/timer_paused

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
	local seconds=$(awk "BEGIN {print int($1 * 60)}")
	while [ $seconds -gt 0 ]; do
		formatted_time=$(printf "%02d:%02d" $((seconds/60)) $((seconds%60)))
		# Repeat paused time each second
		if [[ -f $timer_paused ]]; then
			echo $formatted_time > $timer_file
			sleep 1
			continue
		fi
		echo $formatted_time > $timer_file
		sleep 1
		((seconds--))
	done
	echo "Done" > $timer_file
	notify-send "Time is up!" "Go do the thing you were supposed to do." -i alarm-clock -u critical
	sleep 10
	rm $timer_file
}

pause_option="Pause"
if [[ -f $timer_paused ]]; then
    pause_option="Resume"
else
    pause_option="Pause"
fi

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
	# pkill current file
	pkill -f $(basename $0)
	exit 0
# If input is numbers followed by space min (optional)
elif [[ $input =~ ^([0-9]*\.?[0-9]+)([[:space:]]*min)?$ ]]; then
	rm $timer_paused
	# Find all PIDs with the script name, but exclude the current PID ($$)
	OTHER_PIDS=$(pgrep -f "$(basename "$0")" | grep -v "^$$$")
	if [ -n "$OTHER_PIDS" ]; then
		echo "$OTHER_PIDS" | xargs kill
	fi
	# Extract just the number (first parenthesis)
	minutes=${BASH_REMATCH[1]}
	start_timer $minutes &
	exit 0
else
    exit 1
fi
