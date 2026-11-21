# dotfiles

## New Mac

```bash
git clone https://github.com/jon-peel/my-dotfiles.git ~/dotfiles  # macOS offers to install git first
~/dotfiles/install.sh
```

`install.sh` asks for your admin password once and opens the App Store so you
can sign in. After that it runs unattended:

1. **Preflight**: checks macOS and caches your admin password
2. **App Store**: opens it for sign-in (needed for `mas` apps)
3. **Homebrew**: installs it if missing
4. **Brewfile**: taps, formulae, casks, App Store apps, then any other
   section, each with its own progress list, then a final pass over the whole file
5. **Dotfiles**: links config files into place (`setup-mac.sh`)
6. **Doom Emacs**: clones and installs it, or runs `doom sync` if it's already there

It's safe to re-run: finished steps are skipped.

## What's here

| Path | Linked to |
|---|---|
| `Brewfile` | — (formulae, casks, App Store apps) |
| `dotfiles/zsh/.zshrc` | `~/.zshrc` |
| `dotfiles/zsh/.zprofile` | `~/.zprofile` (PATH) |
| `dotfiles/doom/` | `~/.config/doom` |
| `dotfiles/starship/starship.toml` | `~/.config/starship.toml` |
