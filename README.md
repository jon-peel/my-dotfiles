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
| `dotfiles/rclone/org-bisync.filter` | `~/.config/rclone/` (Linux) |
| `dotfiles/systemd/org-sync.{service,timer}` | `~/.config/systemd/user/` (Linux) |

## New Linux machine

```bash
git clone https://github.com/jon-peel/my-dotfiles.git ~/dotfiles
~/dotfiles/setup-linux.sh          # asks about each option
~/dotfiles/setup-linux.sh --all    # or pick: --org-sync, --doom
```

It always links zsh (`.zshrc`, `.zprofile`) and starship. The options:

- **`--org-sync`** keeps `~/OneDrive/org` in step with OneDrive's `org` folder
  every 5 minutes (`rclone bisync`, systemd user timer), so Doom's
  `org-directory` (`~/OneDrive/org`) works on Linux and macOS alike. It
  installs rclone to `~/.local/bin`. Sign-in is the one manual step: the first
  run prints how (`rclone config`, then `rclone authorize "onedrive"` on a
  machine with a browser), and re-running then does the first sync.
- **`--doom`** installs emacs, git, ripgrep and fd with apt if missing, links
  `~/.config/doom`, and clones and installs Doom Emacs (or runs `doom sync`).

It's safe to re-run: finished steps are skipped.
