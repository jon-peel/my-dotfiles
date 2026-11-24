#!/usr/bin/env bash
# setup-linux.sh — set up a Linux machine from this repo.
#
#   ./setup-linux.sh                    link dotfiles, then ask about each option
#   ./setup-linux.sh --org-sync --doom  link dotfiles and do both, no questions
#
# Options:
#   --org-sync   Sync ~/OneDrive/org with OneDrive every 5 minutes (rclone bisync)
#   --doom       Install Doom Emacs (and emacs, git, ripgrep, fd via apt if missing)
#   --all        Both of the above
#
# With no options it asks about each one; without a terminal it skips them.
# Safe to re-run: every step skips work that's already done.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN="$HOME/.local/bin"
DOOM_DIR="$HOME/.config/emacs"
DOOM_REPO="https://github.com/doomemacs/doomemacs"
ORG_DIR="$HOME/OneDrive/org"
FILTER="$HOME/.config/rclone/org-bisync.filter"

usage() { sed -n '2,13s/^# \{0,1\}//p' "$0"; }

ORG_SYNC=ask DOOM=ask
for arg in "$@"; do
  case $arg in
    --org-sync) ORG_SYNC=yes ;;
    --doom)     DOOM=yes ;;
    --all)      ORG_SYNC=yes DOOM=yes ;;
    -h|--help)  usage; exit 0 ;;
    *)          echo "Unknown option: $arg" >&2; usage >&2; exit 1 ;;
  esac
done
# Any option given means "just these": don't ask about the rest.
(( $# > 0 )) && { [[ $ORG_SYNC == ask ]] && ORG_SYNC=no; [[ $DOOM == ask ]] && DOOM=no; }

say()  { printf '\n\e[1m▸ %s\e[0m\n' "$1"; }
info() { printf '    %s\n' "$1"; }

# want <ask|yes|no> <question>: true if the option should run.
want() {
  case $1 in
    yes) return 0 ;;
    no)  return 1 ;;
  esac
  [[ -t 0 ]] || return 1
  local reply
  read -r -p "$2 [y/N] " reply
  [[ $reply == [yY]* ]]
}

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
  info "${dst/#$HOME/~} -> ${src/#$HOME/~}"
}

# ─── Dotfiles (always) ───────────────────────────────────────────────────────
say "Linking dotfiles"
link "$DOTFILES/dotfiles/zsh/.zshrc"                "$HOME/.zshrc"
link "$DOTFILES/dotfiles/zsh/.zprofile"             "$HOME/.zprofile"
link "$DOTFILES/dotfiles/starship/starship.toml"    "$HOME/.config/starship.toml"
mkdir -p "$BIN"
export PATH="$BIN:$PATH"

# ─── Org sync (optional) ─────────────────────────────────────────────────────
install_rclone() {
  [[ -x $BIN/rclone ]] && { info "rclone already installed ($("$BIN/rclone" version | head -1))"; return; }
  info "Installing rclone to ~/.local/bin (official binary, checksum verified)…"
  local tmp v zip
  tmp=$(mktemp -d)
  v=$(curl -fsSL https://downloads.rclone.org/version.txt | awk '{print $2}')
  zip="rclone-$v-linux-amd64.zip"
  ( cd "$tmp"
    curl -fsSLO "https://downloads.rclone.org/$v/$zip"
    curl -fsSL "https://downloads.rclone.org/$v/SHA256SUMS" | grep " $zip\$" | sha256sum -c --quiet -
    unzip -q "$zip" )
  install -m 755 "$tmp/rclone-$v-linux-amd64/rclone" "$BIN/rclone"
  rm -rf "$tmp"
  info "Installed $("$BIN/rclone" version | head -1)"
}

setup_org_sync() {
  say "Org sync (rclone bisync ~/OneDrive/org)"
  install_rclone

  # One file, not the folder: ~/.config/rclone/rclone.conf holds the OneDrive
  # token and must stay out of git.
  link "$DOTFILES/dotfiles/rclone/org-bisync.filter" "$FILTER"
  link "$DOTFILES/dotfiles/systemd/org-sync.service" "$HOME/.config/systemd/user/org-sync.service"
  link "$DOTFILES/dotfiles/systemd/org-sync.timer"   "$HOME/.config/systemd/user/org-sync.timer"
  systemctl --user daemon-reload

  if ! rclone listremotes | grep -qx 'onedrive:'; then
    info "No rclone remote called 'onedrive' yet. Sign in, then re-run this script:"
    info "  rclone config   → n (new), name: onedrive, storage: onedrive,"
    info "                    blank client_id/secret, region 1, advanced n,"
    info "                    'Use web browser…?' n, then on a machine with a browser"
    info "                    run: rclone authorize \"onedrive\" and paste the token"
    return
  fi

  if [[ -d $ORG_DIR ]]; then
    info "${ORG_DIR/#$HOME/~} already exists; skipping the first --resync"
  else
    info "First sync: downloading OneDrive's org folder to ${ORG_DIR/#$HOME/~}…"
    mkdir -p "$ORG_DIR"
    rclone bisync onedrive:org "$ORG_DIR" --filters-file "$FILTER" \
      --create-empty-src-dirs --compare size,modtime --resync
    info "Downloaded $(find "$ORG_DIR" -type f | wc -l) files"
  fi

  systemctl --user enable --now org-sync.timer
  # Keep the timer running when logged out.
  loginctl enable-linger "$USER" || info "Couldn't enable lingering; sync only runs while you're logged in"
  info "Syncing every 5 minutes; logs: journalctl --user -u org-sync"
}

# ─── Doom Emacs (optional) ───────────────────────────────────────────────────
setup_doom() {
  say "Doom Emacs"
  local missing=() cmd pkg
  for cmd in emacs:emacs git:git rg:ripgrep fdfind:fd-find; do
    command -v "${cmd%%:*}" >/dev/null || missing+=("${cmd#*:}")
  done
  if (( ${#missing[@]} )); then
    info "Installing with apt: ${missing[*]}"
    sudo apt-get install -y "${missing[@]}"
  fi
  # Debian ships fd as `fdfind`; Doom looks for `fd`.
  if ! command -v fd >/dev/null && command -v fdfind >/dev/null; then
    ln -sfn "$(command -v fdfind)" "$BIN/fd"
    info "~/.local/bin/fd -> $(command -v fdfind)"
  fi

  link "$DOTFILES/dotfiles/doom" "$HOME/.config/doom"

  if [[ -x $DOOM_DIR/bin/doom ]]; then
    info "Doom already cloned; syncing config"
    "$DOOM_DIR/bin/doom" sync
  elif [[ -e $DOOM_DIR ]]; then
    info "${DOOM_DIR/#$HOME/~} exists but isn't Doom; move it aside and re-run"
    return 1
  else
    info "Cloning Doom Emacs…"
    git clone --depth 1 "$DOOM_REPO" "$DOOM_DIR"
    info "Installing Doom and its packages (this takes a few minutes)…"
    "$DOOM_DIR/bin/doom" install --no-config --force
  fi
}

# `if`, not `&&`: errexit is ignored inside functions called from an && list.
if want "$ORG_SYNC" "Set up org sync with OneDrive (~/OneDrive/org)?"; then setup_org_sync; fi
if want "$DOOM" "Install Doom Emacs?"; then setup_doom; fi

say "Done. Open a new terminal to pick up the shell config."
