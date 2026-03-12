# Shell Module Design

## Overview

A `my.shell.enable` Home Manager module providing zsh + Starship prompt with vim mode, tab completions, and a verbose developer-focused prompt.

## File Structure

```
modules/
└── shell.nix    # defines my.shell.enable option
```

Imported in `home.nix`, enabled with `my.shell.enable = true;`.

## Components

### programs.zsh

| Feature | Setting |
|---|---|
| Tab completion | `enableCompletion = true` |
| Vim mode | `defaultKeymap = "viins"` |
| Syntax highlighting | `syntaxHighlighting.enable = true` |
| History suggestions | `autosuggestion.enable = true` |

### programs.starship

Verbose prompt segments:

- **Directory** — truncated to 3 segments, `home_symbol = " "` (Nerd Font house glyph, fallback to 🏠)
- **Git branch** — branch name with icon
- **Git status** — ahead/behind, staged, unstaged, untracked counts
- **Exit code** — shown only on failure
- **Command duration** — shown only when > 2s
- **Language versions** — node, python, rust etc., only when in a relevant project directory
- **Vim mode indicator** — `[I]` insert / `[N]` normal

## Non-Goals

- No oh-my-zsh
- No custom themes beyond Starship config
- No font installation (handled separately if needed)
