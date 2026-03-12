# Terminal Module Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create `modules/terminal.nix` providing Ghostty terminal with JetBrains Mono Nerd Font and automatic macOS dark/light Tokyo Night theme switching.

**Architecture:** Same `my.<name>.enable` pattern as existing modules. Font installed via `home.packages` and symlinked into `~/Library/Fonts/` for macOS discovery. Ghostty configured via `programs.ghostty.settings`.

**Tech Stack:** Nix Home Manager, Ghostty, pkgs.nerd-fonts.jetbrains-mono, nixpkgs-unstable

---

### Task 1: Verify available theme names

Ghostty ships built-in themes but their exact names must be confirmed before writing config.

**Step 1: Check if Ghostty is already installed**

```bash
which ghostty || echo "not installed"
```

**Step 2: If installed, list available Tokyo Night themes**

```bash
ghostty +list-themes | grep -i tokyo
```

Expected output: lines containing something like `tokyonight` and `tokyonight_day` (or similar variants).

**Step 3: Note the exact dark and light theme names**

These will be used in Task 2 as `theme = "light:<light-name>,dark:<dark-name>"`.

If Ghostty is not yet installed, use these defaults (correct as of Ghostty 1.x):
- Dark: `tokyonight`
- Light: `tokyonight_day`

---

### Task 2: Create modules/terminal.nix

**Files:**
- Create: `modules/terminal.nix`

**Step 1: Check the JetBrains Mono Nerd Font package path**

```bash
nix eval --raw nixpkgs#nerd-fonts.jetbrains-mono.outPath 2>/dev/null || echo "check manually"
```

Then find the font directory:

```bash
ls $(nix eval --raw nixpkgs#nerd-fonts.jetbrains-mono.outPath)/share/fonts/
```

The font files are typically under `share/fonts/truetype/NerdFonts/` — confirm the exact subdirectory.

**Step 2: Write the file**

```nix
{ config, lib, pkgs, ... }:

{
  options.my.terminal.enable = lib.mkEnableOption "Ghostty terminal with JetBrains Mono Nerd Font";

  config = lib.mkIf config.my.terminal.enable {

    # Install font and make it visible to macOS font system
    home.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

    home.file."Library/Fonts/JetBrainsMonoNF" = {
      source = "${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype/NerdFonts";
      recursive = true;
    };

    programs.ghostty = {
      enable = true;
      settings = {
        font-family = "JetBrainsMono Nerd Font Mono";
        font-size = 12;
        theme = "light:tokyonight_day,dark:tokyonight";
      };
    };

  };
}
```

**Note:** Adjust the `home.file` source path if the font directory found in Step 1 differs from `share/fonts/truetype/NerdFonts`. Adjust `theme` values if the names found in Task 1 differ.

**Step 3: Verify the file was written correctly**

Read back `modules/terminal.nix` and confirm it matches.

**Step 4: Commit**

```bash
git add modules/terminal.nix
git commit -m "feat: add modules/terminal.nix with Ghostty and JetBrains Mono NF"
```

---

### Task 3: Update home.nix

**Files:**
- Modify: `home.nix`

**Step 1: Add the import and enable the module**

```nix
{ ... }: {

  imports = [
    ./modules/git.nix
    ./modules/shell.nix
    ./modules/terminal.nix
  ];

  home.username = "me";
  home.homeDirectory = "/Users/me";
  home.stateVersion = "24.11";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  my.git.enable = true;
  my.shell.enable = true;
  my.terminal.enable = true;

}
```

**Step 2: Verify the file**

Read back `home.nix` and confirm all three imports and all three `my.*.enable` lines are present.

**Step 3: Commit**

```bash
git add home.nix
git commit -m "feat: enable terminal module in home.nix"
```

---

### Task 4: Activate and verify

**Step 1: Switch**

```bash
home-manager switch --flake .#me
```

If it fails with "existing file would be clobbered" for `~/.config/ghostty/config`, run:

```bash
mv ~/.config/ghostty/config ~/.config/ghostty/config.pre-hm
home-manager switch --flake .#me
```

Expected: activation completes without errors.

**Step 2: Open Ghostty**

Launch Ghostty from Spotlight or Applications. Verify:
- Font renders correctly (JetBrains Mono, no missing glyphs)
- Theme matches system appearance (dark in dark mode, light in light mode)
- Toggle macOS dark/light mode (System Settings → Appearance) and confirm Ghostty switches

**Step 3: Verify font size**

Font should appear at size 12. If too small or large, note it — the user will adjust.

**Step 4: Commit flake.lock if updated**

```bash
git diff flake.lock
```

If changed:
```bash
git add flake.lock
git commit -m "chore: update flake.lock"
```

---

## Notes

- `programs.ghostty` was added to Home Manager after Ghostty's December 2024 release. If evaluation fails with "attribute 'ghostty' missing", fall back to managing the config file directly: `home.file.".config/ghostty/config".text = "font-family = JetBrainsMono Nerd Font Mono\nfont-size = 12\ntheme = light:tokyonight_day,dark:tokyonight\n";`
- The font name Ghostty expects is `JetBrainsMono Nerd Font Mono` (with "Mono" suffix) — this is the monospaced variant. If Ghostty shows a fallback font, try `JetBrainsMono Nerd Font` without the suffix.
- `home.file."Library/Fonts/..."` creates a symlink in `~/Library/Fonts/`. macOS will discover fonts here without any additional steps.
