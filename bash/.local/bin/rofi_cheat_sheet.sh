#!/usr/bin/env bash

query=$(rofi -dmenu -i -no-fixed-num-lines \
  -theme-str 'window {width: 20%; }'\
  -p "Cheat Sheet:" <<- EOF
		react
		js
		bash
		lua
	EOF
)

if [[ -n $query ]]; then
	TMUX_SESSION="cheat_sh"
	GET_CHEAT_SHEET="curl cheat.sh/$query; tmux copy-mode; exec bash"

	ghostty --class=com.ghostty.float -e bash -lc "
	tmux has-session -t $TMUX_SESSION 2>/dev/null ||
		tmux new-session -d -s cheat_sh -n \"$query\" \
		\"$GET_CHEAT_SHEET\"

    if tmux list-windows -t $TMUX_SESSION -F '#W' | grep -Fxq \"$query\"; then
      tmux select-window -t $TMUX_SESSION:\"$query\"
    else
      tmux new-window -t $TMUX_SESSION -n \"$query\" \"$GET_CHEAT_SHEET\"
    fi

	tmux attach-session -t $TMUX_SESSION
	"
fi
