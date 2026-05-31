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

# Vi mode for command line editing
set -o vi

# Colours
export TERM=xterm-256color
export COLORTERM=truecolor

# Prompt
PROMPT_COMMAND='PS1_GIT_BRANCH=$(git branch --show-current 2>/dev/null); PS1_GIT=${PS1_GIT_BRANCH:+ ($PS1_GIT_BRANCH)}'
PS1='\n\[\e[38;5;25m\][\A]\[\e[0m\] \[\e[38;5;214;1m\]\w\[\e[0m\]\[\e[38;5;222m\]${PS1_GIT}\n\[\e[0m\]> '

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

# Autostart tmux and attach to the last session
if command -v tmux &> /dev/null \
  && [ -z "$TMUX" ] \
  && [ "$TERM_PROGRAM" = "ghostty" ]; then
  tmux attach-session -t main || tmux new-session -s main
fi

# Show onefetch when the shell starts inside a git repo, otherwise show fastfetch.
if command -v git &> /dev/null \
  && command -v onefetch &> /dev/null \
  && git rev-parse --is-inside-work-tree &> /dev/null; then
  onefetch --include-hidden --no-color-palette
elif command -v fastfetch &> /dev/null; then
  fastfetch
fi

# Yazi cd to directory
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# Nvim alias
alias vim="nvim"
alias v="nvim"

# Lazygit alias
alias lg="lazygit"

# Zed alias
alias zed="zeditor --wait ."

# opencode alias
alias oc="opencode"

# python virtual env
alias py="python"
alias venv="source .venv/bin/activate"

# start dev server script
alias dev="start-dev-server.sh"

# open nvim + pi layout in tmux (vim + ai)
alias va="open-nvim-pi-layout.sh"

# Select and go to t3 code worktree
alias wt="source t3code-wt-switcher.sh"
