# Void Experience Zsh profile.
# This file is project-owned; keep private exports and machine-specific settings
# in ~/.zshrc outside the managed source block.

export STARSHIP_CONFIG="$HOME/.config/void-experience/zsh/starship.toml"

HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY
setopt APPEND_HISTORY

autoload -Uz compinit
zsh_cache_dir="$HOME/.cache/zsh"
[[ -d "$zsh_cache_dir" ]] || mkdir -p "$zsh_cache_dir"
compinit -d "$zsh_cache_dir/zcompdump"
unset zsh_cache_dir

if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'

if (( $+commands[eza] )); then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -lah --icons --git --group-directories-first'
  alias la='eza -a --icons'
  alias tree='eza --tree --icons'
fi

if (( $+commands[batcat] )); then
  alias bat='batcat'
  alias cat='batcat'
elif (( $+commands[bat] )); then
  alias cat='bat'
fi

if (( $+commands[rg] )); then
  alias grep='rg'
fi
if (( $+commands[fd] )); then
  alias find='fd'
elif (( $+commands[fdfind] )); then
  alias fd='fdfind'
  alias find='fdfind'
fi

(( $+commands[fastfetch] )) && alias ff='fastfetch'
(( $+commands[btop] )) && alias bt='btop'

if [[ -r /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
if [[ -r /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Syntax highlighting must be sourced late; Starship initialization comes last.
if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi
