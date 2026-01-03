# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Colored outputs
alias ls="ls --color=auto"
alias grep="grep --color=auto"

# Colours
export TERM=xterm-256color
export COLORTERM=truecolor

# Prompt Variables
Blue="\[\e[0;34m\]"
Blue_Bold="\[\e[1;34m\]"
Gold="\[\e[0;33m\]"
Gold_Bold="\[\e[1;33m\]"
Reset="\[\e[0m\]"
function git_branch() {
     git branch 2> /dev/null | sed -e "/^[^*]/d" -e "s/* \(.*\)/ (\1)/"
}
# Prompt
export PS1="${Blue}[\A]${Blue_Bold}\u ${Gold_Bold}\w${Gold}\$(git_branch)${Blue}: ${Reset}"

# Bash Tab Completion
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi

# Environment Variables
export EDITOR=nvim
export PATH="$HOME/.local/bin:$PATH"
export PATH=$PATH:/home/leoz/.spicetify
. "$HOME/.cargo/env"
# Seperate file for api key env variables
[ -f "$HOME/.bash_secrets" ] && . "$HOME/.bash_secrets"

# Zoxide
eval "$(zoxide init bash)"

# Fastfetch
fastfetch

# Yazi cd to directory
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# Lazygit alias
alias lg="lazygit"

# Autostart tmux and attach to the last session
if [ -z "$TMUX" ]; then
	last_session=$(tmux list-sessions -F '#{session_last_attached} #S' 2>/dev/null | \
		sort -rn | \
		head -1 | \
		awk '{print $2}')

		if [ -n "$last_session" ]; then
			tmux attach-session -t "$last_session"
		else
			tmux new-session -s "main"
		fi
fi
