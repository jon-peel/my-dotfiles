#!/usr/bin/env bash
# install.sh — set up a new Mac from this repo.
#
#   1. Preflight      admin password, kept alive for the whole run
#   2. App Store      opens it so you can sign in (needed for `mas` apps)
#   3. Homebrew       installs it if missing
#   4. Brewfile       one section at a time (tap, brew, cask, mas, …),
#                     then a pass over the whole file
#   5. Dotfiles       links config files into place (setup-mac.sh)
#   6. Doom Emacs     clones and installs, or syncs if already there
#
# Safe to re-run: every step skips work that's already done.
# Written for the bash 3.2 that ships with macOS.

set -uo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$DOTFILES/Brewfile"
DOOM_DIR="$HOME/.config/emacs"
DOOM_REPO="https://github.com/doomemacs/doomemacs"

TOTAL_STAGES=6
STAGE=0
FAILURES=()
START=$SECONDS

# ─── Look ────────────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  BOLD=$'\e[1m'; DIM=$'\e[2m'; RESET=$'\e[0m'
  RED=$'\e[31m'; GREEN=$'\e[32m'; YELLOW=$'\e[33m'; BLUE=$'\e[34m'; CYAN=$'\e[36m'
else
  BOLD=; DIM=; RESET=; RED=; GREEN=; YELLOW=; BLUE=; CYAN=
fi

elapsed() { # seconds → "1m 05s" / "42s"
  local s=$1
  if (( s >= 60 )); then printf '%dm %02ds' $((s / 60)) $((s % 60)); else printf '%ds' "$s"; fi
}

stage() {
  STAGE=$((STAGE + 1)); STAGE_START=$SECONDS
  printf '\n%s━━━ [%d/%d] %s %s%s\n' "$BOLD$BLUE" "$STAGE" "$TOTAL_STAGES" "$1" \
    "$(printf '━%.0s' $(seq 1 $((60 - ${#1}))))" "$RESET"
}
stage_done() { printf '%s    ✓ done in %s%s\n' "$DIM" "$(elapsed $((SECONDS - STAGE_START)))" "$RESET"; }
substage()   { printf '\n  %s▸ %s%s\n' "$BOLD$CYAN" "$1" "$RESET"; }
info()       { printf '    %s\n' "$1"; }
ok()         { printf '    %s✓%s %s\n' "$GREEN" "$RESET" "$1"; }
warn()       { printf '    %s!%s %s\n' "$YELLOW" "$RESET" "$1"; }
fail()       { printf '    %s✗%s %s\n' "$RED" "$RESET" "$1"; FAILURES+=("$1"); }
ask()        { printf '\n    %s?%s %s' "$YELLOW" "$RESET" "$1"; read -r _ </dev/tty; }

# ─── 1. Preflight ────────────────────────────────────────────────────────────
printf '\n%sSetting up this Mac from %s%s\n' "$BOLD" "$DOTFILES" "$RESET"

stage "Preflight"
[[ $(uname -s) == Darwin ]] || { fail "This script is for macOS."; exit 1; }
ok "macOS $(sw_vers -productVersion) on $(uname -m)"
[[ -f $BREWFILE ]] || { fail "No Brewfile at $BREWFILE"; exit 1; }
ok "Brewfile found"

info "Some installers need your admin (login) password; asking once now."
sudo -v || { fail "Admin password is needed."; exit 1; }
# Keep sudo alive until this script exits, so later installers don't stall.
( while kill -0 $$ 2>/dev/null; do sudo -n true; sleep 50; done ) 2>/dev/null &
ok "Admin access cached"
stage_done

# ─── 2. App Store ────────────────────────────────────────────────────────────
stage "App Store sign-in"
if grep -Eq '^[[:space:]]*mas[[:space:]]' "$BREWFILE"; then
  info "Apps from the Mac App Store need you to be signed in."
  info "Apple doesn't allow scripted sign-in, so the App Store will open now."
  open -a "App Store"
  ask "Sign in (Account → Sign In), then press Enter to continue… "
  ok "Continuing; the rest runs unattended"
else
  ok "No App Store apps in the Brewfile, skipping"
fi
stage_done

# ─── 3. Homebrew ─────────────────────────────────────────────────────────────
stage "Homebrew"
find_brew() {
  local b
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -x $b ]] && { eval "$("$b" shellenv)"; return 0; }
  done
  return 1
}
if find_brew; then
  ok "Already installed ($(brew --version | head -1))"
else
  info "Installing Homebrew (also installs Xcode Command Line Tools)…"
  if NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
     && find_brew; then
    ok "Installed $(brew --version | head -1)"
  else
    fail "Homebrew install failed; can't continue."; exit 1
  fi
fi
stage_done

# ─── 4. Brewfile ─────────────────────────────────────────────────────────────
stage "Brewfile"
WORK=$(mktemp -d); trap 'rm -rf "$WORK"' EXIT

# Entry types in the order they should install. Any other type found in the
# Brewfile (go, cargo, uv, npm, vscode, …) runs after these, in file order.
PREFERRED="tap brew cask mas"
label_for() {
  case $1 in
    tap) echo "Taps" ;; brew) echo "Formulae (CLI tools)" ;; cask) echo "Casks (apps & fonts)" ;;
    mas) echo "Mac App Store apps" ;; *) echo "$1 packages" ;;
  esac
}

# Every entry type that appears in the Brewfile, in first-seen order.
FOUND=$(awk '$1 !~ /^#/ && NF { print $1 }' "$BREWFILE" | awk '!seen[$0]++')
SECTIONS=""
for t in $PREFERRED; do echo "$FOUND" | grep -qx "$t" && SECTIONS="$SECTIONS $t"; done
for t in $FOUND;     do case " $PREFERRED " in *" $t "*) ;; *) SECTIONS="$SECTIONS $t" ;; esac; done

# Run `brew bundle` on one file, turning its output into a progress list.
bundle() { # bundle <file> <count>
  local file=$1 total=$2 n=0 line verb name mark
  brew bundle --file="$file" 2>&1 | while IFS= read -r line; do
    case $line in
      Using\ *|Installing\ *|Tapping\ *|Upgrading\ *|Skipping\ *)
        verb=${line%% *}; name=${line#* }
        case $name in
          *" has failed!") printf '            %s✗ %s failed%s\n' "$RED" "${name% has failed!}" "$RESET"; continue ;;
        esac
        n=$((n + 1))
        case $verb in
          Using)    mark="$GREEN✓$RESET"; name="$name $DIM(already installed)$RESET" ;;
          Skipping) mark="$YELLOW–$RESET"; name="$name $DIM(skipped)$RESET" ;;
          *)        mark="$CYAN→$RESET";  name="$BOLD$name$RESET $DIM($(echo "$verb" | tr '[:upper:]' '[:lower:]'))$RESET" ;;
        esac
        printf '    %s[%*d/%d]%s %s %s\n' "$DIM" "${#total}" "$n" "$total" "$RESET" "$mark" "$name" ;;
      '`brew bundle` complete'*|*'JSON API'*|'==> Downloading Homebrew API data') ;;
      *) printf '            %s%s%s\n' "$DIM" "$line" "$RESET" ;;
    esac
  done
  return "${PIPESTATUS[0]}"
}

for t in $SECTIONS; do
  file="$WORK/$t.Brewfile"
  awk -v t="$t" '$1 == t' "$BREWFILE" > "$file"
  count=$(wc -l < "$file" | tr -d ' ')
  substage "$(label_for "$t") — $count"
  if [[ $t == mas ]] && ! command -v mas >/dev/null; then
    info "Installing mas (App Store command-line tool) first…"
    brew install mas >/dev/null 2>&1 || warn "Couldn't install mas"
  fi
  t0=$SECONDS
  if bundle "$file" "$count"; then
    ok "$(label_for "$t") done in $(elapsed $((SECONDS - t0)))"
  else
    fail "Some $(label_for "$t" | tr '[:upper:]' '[:lower:]') didn't install (details above)"
  fi
done

substage "Whole Brewfile — final check"
if brew bundle check --no-upgrade --file="$BREWFILE" >/dev/null 2>&1; then
  ok "Everything in the Brewfile is installed"
else
  info "Something is still missing; running the whole Brewfile once more…"
  total=$(awk '$1 !~ /^#/ && NF' "$BREWFILE" | wc -l | tr -d ' ')
  if bundle "$BREWFILE" "$total"; then ok "Whole Brewfile installed"
  else fail "The whole-Brewfile pass reported errors (details above)"; fi
fi
stage_done

# ─── 5. Dotfiles ─────────────────────────────────────────────────────────────
stage "Link dotfiles"
if out=$(bash "$DOTFILES/setup-mac.sh" 2>&1); then
  echo "$out" | sed -n 's/^  \(.*\) -> .*/\1/p' | while read -r l; do ok "${l/#$HOME/~}"; done
else
  echo "$out"; fail "Linking dotfiles failed"
fi
stage_done

# ─── 6. Doom Emacs ───────────────────────────────────────────────────────────
stage "Doom Emacs"
if [[ -x $DOOM_DIR/bin/doom ]]; then
  ok "Doom already cloned; syncing config"
  "$DOOM_DIR/bin/doom" sync || fail "doom sync failed"
elif [[ -e $DOOM_DIR ]]; then
  fail "$DOOM_DIR exists but isn't Doom; move it aside and re-run"
else
  info "Cloning Doom Emacs…"
  if git clone --depth 1 "$DOOM_REPO" "$DOOM_DIR"; then
    ok "Cloned to $DOOM_DIR"
    info "Installing Doom and its packages (this takes a few minutes)…"
    "$DOOM_DIR/bin/doom" install --no-config --force && ok "Doom installed" || fail "doom install failed"
  else
    fail "Couldn't clone Doom Emacs"
  fi
fi
stage_done

# ─── Summary ─────────────────────────────────────────────────────────────────
printf '\n%s━━━ Finished in %s ' "$BOLD" "$(elapsed $((SECONDS - START)))"
printf '━%.0s' $(seq 1 46); printf '%s\n' "$RESET"
if (( ${#FAILURES[@]} == 0 )); then
  ok "Everything went fine."
else
  warn "${#FAILURES[@]} problem(s):"
  for f in "${FAILURES[@]}"; do printf '      %s•%s %s\n' "$RED" "$RESET" "$f"; done
  info "Fix them and re-run; finished steps are skipped."
fi
info "Open a new terminal window to pick up the new shell config."
echo
