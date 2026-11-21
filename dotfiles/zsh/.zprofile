# ~/.zprofile — login shells. PATH lives here (not .zshenv) because macOS's
# /etc/zprofile runs path_helper, which reorders anything set earlier.

# Homebrew: sets PATH, MANPATH, fpath and HOMEBREW_PREFIX.
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  [[ -x $_brew ]] && { eval "$($_brew shellenv zsh)"; break; }
done
unset _brew

typeset -U path   # drop duplicate entries

# Prepend: user tools win over system ones.
path=(
  $HOME/.local/bin          # uv tools
  $HOME/.cargo/bin          # cargo install
  $path
)

# Append, only if the folder exists on this machine.
for _dir in \
  "$HOME/.config/emacs/bin" \
  "$HOME/.dotnet/tools" \
  "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
do
  [[ -d $_dir ]] && path+=("$_dir")
done
unset _dir
