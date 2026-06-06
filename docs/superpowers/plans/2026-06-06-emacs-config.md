# Emacs Config from Scratch — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a minimal, hand-rolled `init.el` with `package.el` + `use-package` and `meow` modal editing (QWERTY layout).

**Architecture:** Single `init.el` file in `dotfiles/dotfiles/emacs/`. No modules, no framework. `package.el` (built-in) handles package sources; `use-package` (built-in since Emacs 29) handles package declaration and lazy loading; `meow` provides modal editing with a selection-first model distinct from vim/evil.

**Tech Stack:** Emacs 29+, `package.el`, `use-package`, `meow` (MELPA)

---

### Task 1: Bootstrap package.el + use-package

**Files:**
- Create: `dotfiles/dotfiles/emacs/init.el`

- [ ] **Step 1: Create init.el with package bootstrap**

  Create `dotfiles/dotfiles/emacs/init.el` with this exact content:

  ```elisp
  ;;; init.el -*- lexical-binding: t; -*-

  ;;; Package bootstrap
  (require 'package)
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
  (package-initialize)

  (require 'use-package)
  (setq use-package-always-ensure t)
  ```

  `lexical-binding: t` in the first line enables lexical scope for the whole file — always do this.
  `use-package-always-ensure t` means every `use-package` call will install the package if missing, so you don't need `:ensure t` on every declaration.

- [ ] **Step 2: Verify Emacs starts cleanly**

  Start Emacs pointing at this directory:

  ```bash
  emacs --init-directory ~/dotfiles/dotfiles/emacs/
  ```

  Check the `*Messages*` buffer (open with `C-x b *Messages* RET`). Expected: no lines containing `Error` or `Warning`. You will see messages like `Loading ~/.../init.el...` and `done` — that is normal.

- [ ] **Step 3: Commit**

  ```bash
  git add dotfiles/dotfiles/emacs/init.el
  git commit -m "feat: init emacs config with package.el + use-package bootstrap"
  ```

---

### Task 2: Add meow modal editing

**Files:**
- Modify: `dotfiles/dotfiles/emacs/init.el`

- [ ] **Step 1: Append meow setup to init.el**

  Add the following after the package bootstrap block in `dotfiles/dotfiles/emacs/init.el`:

  ```elisp
  ;;; Meow — modal editing
  (defun meow-setup ()
    (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
    (meow-motion-overwrite-define-key
     '("j" . meow-next)
     '("k" . meow-prev)
     '("<escape>" . ignore))
    (meow-leader-define-key
     '("j" . "H-j")
     '("k" . "H-k")
     '("1" . meow-digit-argument)
     '("2" . meow-digit-argument)
     '("3" . meow-digit-argument)
     '("4" . meow-digit-argument)
     '("5" . meow-digit-argument)
     '("6" . meow-digit-argument)
     '("7" . meow-digit-argument)
     '("8" . meow-digit-argument)
     '("9" . meow-digit-argument)
     '("0" . meow-digit-argument)
     '("/" . meow-keypad-describe-key)
     '("?" . meow-cheatsheet))
    (meow-normal-define-key
     '("0" . meow-expand-0)
     '("9" . meow-expand-9)
     '("8" . meow-expand-8)
     '("7" . meow-expand-7)
     '("6" . meow-expand-6)
     '("5" . meow-expand-5)
     '("4" . meow-expand-4)
     '("3" . meow-expand-3)
     '("2" . meow-expand-2)
     '("1" . meow-expand-1)
     '("-" . negative-argument)
     '(";" . meow-reverse)
     '("," . meow-inner-of-thing)
     '("." . meow-bounds-of-thing)
     '("[" . meow-beginning-of-thing)
     '("]" . meow-end-of-thing)
     '("a" . meow-append)
     '("A" . meow-open-below)
     '("b" . meow-back-word)
     '("B" . meow-back-symbol)
     '("c" . meow-change)
     '("d" . meow-delete)
     '("D" . meow-backward-delete)
     '("e" . meow-next-word)
     '("E" . meow-next-symbol)
     '("f" . meow-find)
     '("g" . meow-cancel-selection)
     '("G" . meow-grab)
     '("h" . meow-left)
     '("H" . meow-left-expand)
     '("i" . meow-insert)
     '("I" . meow-open-above)
     '("j" . meow-next)
     '("J" . meow-next-expand)
     '("k" . meow-prev)
     '("K" . meow-prev-expand)
     '("l" . meow-right)
     '("L" . meow-right-expand)
     '("m" . meow-join)
     '("n" . meow-search)
     '("o" . meow-block)
     '("O" . meow-to-block)
     '("p" . meow-yank)
     '("P" . meow-yank-pop)
     '("q" . meow-quit)
     '("Q" . meow-goto-line)
     '("r" . meow-replace)
     '("R" . meow-swap-grab)
     '("s" . meow-kill)
     '("t" . meow-till)
     '("u" . meow-undo)
     '("U" . meow-undo-in-selection)
     '("v" . meow-visit)
     '("w" . meow-mark-word)
     '("W" . meow-mark-symbol)
     '("x" . meow-line)
     '("X" . meow-goto-line)
     '("y" . meow-save)
     '("Y" . meow-sync-grab)
     '("z" . meow-pop-selection)
     '("'" . repeat)
     '("<escape>" . ignore)))

  (use-package meow
    :config
    (meow-setup)
    (meow-global-mode 1))
  ```

  Key things to understand about this layout:
  - `h`/`j`/`k`/`l` — left/down/up/right (same as vim)
  - `w`/`b`/`e` — mark word forward/backward/next (selection-first: select then act)
  - `x` — mark line; `o` — mark block (sexp/paragraph)
  - `s` — kill (cut) selection; `d` — delete char; `c` — change
  - `y` — save (copy) selection; `p` — yank (paste)
  - `u` — undo; `n` — search next
  - `SPC` is the leader key (set automatically by meow-global-mode)
  - `SPC ?` opens the meow cheatsheet

- [ ] **Step 2: Restart Emacs and verify meow installs and activates**

  Quit Emacs (`C-x C-c`) then restart:

  ```bash
  emacs --init-directory ~/dotfiles/dotfiles/emacs/
  ```

  On first run, Emacs will contact MELPA and download `meow`. This takes a few seconds. When it finishes:

  - The modeline should show `NORMAL` (meow's normal state indicator) in the current buffer
  - Press `SPC ?` to open the meow cheatsheet — if it opens, meow is wired up correctly
  - Check `*Messages*` — no errors expected

- [ ] **Step 3: Commit**

  ```bash
  git add dotfiles/dotfiles/emacs/init.el
  git commit -m "feat: add meow modal editing with QWERTY layout"
  ```

---

### Notes for future sessions

The next things commonly added to a config like this, in rough priority order:

1. **which-key** — shows available keybindings after a prefix; invaluable while learning
2. **vertico + orderless** — minibuffer completion (replaces the default)
3. **corfu** — in-buffer completion (replaces the default)
4. **theme** — e.g. `modus-themes` (built-in since Emacs 28) or `doom-themes`
5. **magit** — git UI
6. **org-mode config** — you had a lot of this in Doom; port piece by piece
7. **language/LSP support** — per language, as needed
