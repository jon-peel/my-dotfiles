# ~/.zshrc — interactive shells. PATH is set in ~/.zprofile.

# ── History ──────────────────────────────────────────────────────────────────
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_FCNTL_LOCK HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY

# ── Completion ───────────────────────────────────────────────────────────────
# Extra completion functions (e.g. _openspec) go in ~/.zsh/completions.
fpath=("$HOME/.zsh/completions" $fpath)
autoload -Uz compinit && compinit

[[ -r $HOME/.openclaw/completions/openclaw.zsh ]] && source "$HOME/.openclaw/completions/openclaw.zsh"

# ── Aliases ──────────────────────────────────────────────────────────────────
if ls --color=auto -d . &>/dev/null; then   # GNU ls (Linux)
  alias ls='ls --color=auto'
else                                        # BSD ls (macOS)
  alias ls='ls -G'
fi
alias ll='ls -lh'
alias la='ls -lah'

# ── Prompt ───────────────────────────────────────────────────────────────────
if [[ $TERM != dumb ]] && (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi

# ── Vim mode ─────────────────────────────────────────────────────────────────
bindkey -v

# Esc acts immediately instead of waiting 0.4s to see if a longer sequence follows.
KEYTIMEOUT=1

# Cursor follows the mode: block in normal, beam in insert. Registered as hooks
# so they compose with zsh-syntax-highlighting's widgets instead of clobbering them.
autoload -Uz add-zle-hook-widget
_vim_cursor_for_keymap() {
  case ${KEYMAP:-viins} in
    vicmd|visual) print -n '\e[2 q' ;;
    *)            print -n '\e[6 q' ;;
  esac
}
_vim_cursor_reset() { print -n '\e[6 q' }
add-zle-hook-widget keymap-select _vim_cursor_for_keymap
add-zle-hook-widget line-init     _vim_cursor_for_keymap
add-zle-hook-widget line-finish   _vim_cursor_reset

# Backspace and ctrl-w cross the point where insert mode began; the stock vi
# bindings refuse to delete past it.
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-delete-char
bindkey -M viins '^W' backward-kill-word
bindkey -M viins '^U' backward-kill-line

# Keep the emacs-style keys muscle memory still reaches for while in insert.
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line
bindkey -M viins '^R' history-incremental-search-backward
bindkey -M vicmd '^R' history-incremental-search-backward

# `v` in normal mode opens the current line in $EDITOR (falls back to vi);
# save and quit to run it.
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line

# Text objects: ci" da( yi{ and friends.
autoload -Uz select-quoted select-bracketed
zle -N select-quoted
zle -N select-bracketed
for _km in viopp visual; do
  for _c in {a,i}${(s..)^:-\'\"\`}; do
    bindkey -M $_km $_c select-quoted
  done
  for _c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
    bindkey -M $_km $_c select-bracketed
  done
done
unset _km _c

# ── Plugins ──────────────────────────────────────────────────────────────────
# Installed by Homebrew on macOS, or the distro package manager on Linux.
# zsh-syntax-highlighting must be sourced last so it wraps every widget above.
_zsh_plugin() {
  local dir
  for dir in ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share} /usr/share /usr/share/zsh/plugins; do
    [[ -r $dir/$1/$1.zsh ]] && { source "$dir/$1/$1.zsh"; return; }
  done
}
ZSH_AUTOSUGGEST_STRATEGY=(history)
_zsh_plugin zsh-autosuggestions
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)
_zsh_plugin zsh-syntax-highlighting
unfunction _zsh_plugin

export PATH="$HOME/.local/bin:$PATH"
