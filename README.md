# dotfiles

## New Mac

```bash
# 1. Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Sign in to the App Store, then install everything
brew bundle --file=~/dotfiles/Brewfile

# 3. Link config files into place
~/dotfiles/setup-mac.sh

# 4. Doom Emacs (first time only)
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install
```

## What's here

| Path | Linked to |
|---|---|
| `Brewfile` | — (formulae, casks, App Store apps) |
| `dotfiles/zsh/.zshrc` | `~/.zshrc` |
| `dotfiles/zsh/.zprofile` | `~/.zprofile` (PATH) |
| `dotfiles/doom/` | `~/.config/doom` |
| `dotfiles/starship/starship.toml` | `~/.config/starship.toml` |
