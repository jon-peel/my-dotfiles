# Emacs Config from Scratch — Design Spec

**Date:** 2026-06-06
**Status:** Approved

---

## Goal

Start a minimal, hand-rolled Emacs config with no framework (no Doom, no Spacemacs). The config lives temporarily at `dotfiles/dotfiles/emacs/` and will be moved to a permanent location later. The design philosophy is: start with the absolute minimum and add things only when needed.

---

## Decisions Made

| Concern | Decision | Rationale |
|---|---|---|
| Package manager | `package.el` + `use-package` | Both built-in to Emacs 29+. Zero bootstrap code. Simplest path. |
| Modal editing | `meow` (QWERTY layout) | Modal editing native to Emacs; avoids vim-compat shims that evil requires. |
| Keybindings | Meow QWERTY defaults | Standard layout with hjkl navigation, selection-first editing model. |

---

## File Structure

```
dotfiles/emacs/
└── init.el       # Single file for now; split into modules only when it grows unwieldy
```

---

## init.el Contents

### 1. Package bootstrap

Configure `package.el` with MELPA alongside the default ELPA archive. Call `package-initialize`. Enable `use-package` (built-in) with `:ensure t` as the default so every `use-package` declaration auto-installs its package.

### 2. Meow setup

Install `meow` via `use-package`. Define the standard QWERTY keymap using meow's own `meow-setup` convention:

- **MOTION state** — `j`/`k` for next/prev line; `<escape>` ignored (exits to NORMAL via mode switching)
- **NORMAL state** — hjkl movement, selection-first verbs (w/b/e for word, x for line, o for block), meow's expand system (0-9), standard edit verbs (d delete, s kill, c change, r replace, y save, p yank, u undo)
- **Leader** — `SPC` opens the leader map; digit arguments on `SPC 0-9`; `SPC ?` shows cheatsheet

Enable `meow-global-mode`.

### 3. Nothing else

No theme, no completion framework, no which-key, no org config, no language modes. Those are future decisions.

---

## What Is Explicitly Out of Scope (for now)

- Theme
- Completion (vertico, corfu, orderless)
- which-key
- Org mode config
- Language/LSP support
- Magit
- Terminal emulator (eat)
- Nix home-manager wiring (will be done when config moves to permanent location)

---

## Success Criteria

- `emacs --init-directory ~/path/to/emacs/` starts cleanly with no errors
- Meow is active with QWERTY bindings
- `use-package` declarations with `:ensure t` install packages from MELPA automatically on first run
