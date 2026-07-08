# ==============================================================================
# Environment
# ==============================================================================

export EDITOR=nvim
export TERM=xterm-256color
export COLORTERM=truecolor
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/home/leoz/.spicetify"

# This must be set before interactive shell check so tmux/scripts can see it.
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

# If not running interactively, don't do anything below here.
[[ $- != *i* ]] && return

# ==============================================================================
# Language/toolchain setup
# ==============================================================================

# rust
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# pnpm
export PNPM_HOME="/home/leoz/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

# secrets
[ -f "$HOME/.bash_secrets" ] && source "$HOME/.bash_secrets"

# ==============================================================================
# Zsh options, history, and prompt
# ==============================================================================

setopt PROMPT_SUBST
# Prevent Ctrl-D from exiting the shell accidentally.
setopt IGNORE_EOF

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

precmd() {
  local git_branch
  git_branch=$(git branch --show-current 2>/dev/null)
  PS1_GIT=${git_branch:+ ($git_branch)}
}

PROMPT=$'\n%F{214}%B%~%b%f%F{245}${PS1_GIT}%f\n❯ '

# ==============================================================================
# Completion and keybindings
# ==============================================================================

zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
zstyle ':completion:*' verbose yes
zstyle ':completion:*' group-name ''

autoload -Uz compinit
compinit

zmodload zsh/complist
bindkey -M menuselect 'h' backward-char
bindkey -M menuselect 'j' down-line-or-history
bindkey -M menuselect 'k' up-line-or-history
bindkey -M menuselect 'l' forward-char

# Complete hidden files in glob completions.
_comp_options+=(globdots)

# Vi mode for command line editing.
bindkey -v
KEYTIMEOUT=1

# ==============================================================================
# Plugins and shell integrations
# ==============================================================================

# Autosuggestions
if [[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [[ -r /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# Zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# Syntax highlighting should be loaded last.
if [[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ -r /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# ==============================================================================
# Aliases
# ==============================================================================

# Colored outputs
alias ls="ls --color=auto"
alias grep="grep --color=auto"

# Editors
alias vim="nvim"
alias v="nvim"
alias zed="zeditor --wait ."

# CLIs
alias lg="lazygit"
alias oc="opencode"

# Python
alias py="python"
alias venv="source .venv/bin/activate"

# Scripts
alias dev="start-dev-server.sh"
alias devc="start-dev-server.sh --convex"

alias wtc="wtc.sh"
alias wt="source t3code-wt-switcher.sh"

# System cleanup script
alian cleanup="system-cleanup.sh"

# ==============================================================================
# Functions
# ==============================================================================

# Yazi cd to directory
y() {
  local tmp cwd
  tmp=$(mktemp -t "yazi-cwd.XXXXXX") || return
  yazi "$@" --cwd-file="$tmp"
  cwd=$(<"$tmp")
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

# ==============================================================================
# Startup
# ==============================================================================

# Autostart Herdr and attach to the default session.
if command -v herdr >/dev/null 2>&1 \
  && [ -z "$HERDR_ENV" ] \
  && [ -z "$TMUX" ] \
  && [ "$TERM_PROGRAM" = "ghostty" ]; then
  herdr
fi

# Show onefetch when the shell starts inside a git repo, otherwise show fastfetch.
if command -v git >/dev/null 2>&1 \
  && command -v onefetch >/dev/null 2>&1 \
  && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  onefetch --include-hidden --no-color-palette
elif command -v fastfetch >/dev/null 2>&1; then
  fastfetch
fi
