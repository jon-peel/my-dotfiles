#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
  echo "  $dst -> $src"
}

echo "Setting up dotfiles symlinks..."
link "$DOTFILES/dotfiles/doom"              "$HOME/.config/doom"
link "$DOTFILES/dotfiles/zsh/.zshrc"        "$HOME/.zshrc"
link "$DOTFILES/dotfiles/starship/starship.toml" "$HOME/.config/starship.toml"
echo "Done."
