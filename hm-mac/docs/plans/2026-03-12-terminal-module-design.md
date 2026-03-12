# Terminal Module Design

## Overview

A `my.terminal.enable` Home Manager module providing Ghostty terminal with JetBrains Mono Nerd Font and automatic macOS dark/light theme switching using Tokyo Night.

## File Structure

```
modules/
└── terminal.nix    # defines my.terminal.enable option
```

Imported in `home.nix`, enabled with `my.terminal.enable = true;`.

## Components

### Font

- Package: `pkgs.nerd-fonts.jetbrains-mono`
- Installed to `~/Library/Fonts/` via `home.file` so macOS font system discovers it

### programs.ghostty

| Setting | Value |
|---|---|
| `font-family` | `JetBrainsMono Nerd Font` |
| `font-size` | `12` |
| `theme` | `light:tokyonight_day,dark:tokyonight` |

Automatic OS dark/light switching via Ghostty's native `light:X,dark:Y` theme syntax.

## Non-Goals

- No custom keybindings (Ghostty defaults are sensible)
- No window opacity/blur (can be added later)
- No shell integration beyond what Ghostty enables by default
