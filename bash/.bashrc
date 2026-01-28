# fzf style (if dir ls, else cat)
# This must be set before interactive shell check so tmux scripts can see it
export FZF_DEFAULT_OPTS="
--border=none
--preview '
if [ -d {} ]; then
  ls --color=always {};
else
  bat --style=plain --color=always --theme=ansi {};
fi
'
--preview-window='right:50%'
--color='bg:-1,bg+:#132a40,fg:#c0caf5,fg+:#c0caf5'
--color='hl:#6A95DF,hl+:#9DB9F5,info:#dfb46a,prompt:#6A95DF'
--color='pointer:#dfb46a,marker:#dfb46a,spinner:#dfb46a,header:#3a415c'
"

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
export PS1="${Blue}[\A] ${Gold_Bold}\w${Gold}\$(git_branch)${Blue}: ${Reset}"

# Bash Tab Completion
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi

# Environment Variables
export EDITOR=nvim
export PATH="$HOME/.local/bin:$PATH"
export PATH=$PATH:/home/leoz/.spicetify
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
# pnpm
export PNPM_HOME="/home/leoz/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
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
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
  tmux attach-session -t main || tmux new-session -s main
fi

# Zed alias
alias zed="zeditor --wait ."
