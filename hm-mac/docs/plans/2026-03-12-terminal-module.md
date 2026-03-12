# Terminal Module Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create `modules/terminal.nix` providing WezTerm terminal with JetBrains Mono Nerd Font and automatic macOS dark/light Tokyo Night theme switching.

**Architecture:** Same `my.<name>.enable` pattern as existing modules. Font installed via `home.packages` and symlinked into `~/Library/Fonts/` for macOS discovery. WezTerm configured via `programs.wezterm.extraConfig` (Lua).

**Tech Stack:** Nix Home Manager, WezTerm, pkgs.nerd-fonts.jetbrains-mono, nixpkgs-unstable

---

### Task 1: Create modules/terminal.nix

**Files:**
- Create: `modules/terminal.nix`

**Step 1: Write the file**

```nix
{ config, lib, pkgs, ... }:

{
  options.my.terminal.enable = lib.mkEnableOption "WezTerm terminal with JetBrains Mono Nerd Font";

  config = lib.mkIf config.my.terminal.enable {

    # Install font and make it visible to macOS font system
    home.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

    home.file."Library/Fonts/JetBrainsMonoNF" = {
      source = "${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype/NerdFonts/JetBrainsMono";
      recursive = true;
    };

    programs.wezterm = {
      enable = true;
      extraConfig = ''
        local wezterm = require 'wezterm'
        local config = wezterm.config_builder()

        config.font = wezterm.font 'JetBrainsMono Nerd Font Mono'
        config.font_size = 12.0

        -- Automatic dark/light theme based on macOS appearance
        local function scheme_for_appearance(appearance)
          if appearance:find 'Dark' then
            return 'Tokyo Night'
          else
            return 'Tokyo Night Day'
          end
        end

        config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())

        wezterm.on('window-config-reloaded', function(window)
          local overrides = window:get_config_overrides() or {}
          local appearance = window:get_appearance()
          local scheme = scheme_for_appearance(appearance)
          if overrides.color_scheme ~= scheme then
            overrides.color_scheme = scheme
            window:set_config_overrides(overrides)
          end
        end)

        return config
      '';
    };

  };
}
```

**Step 2: Verify the file was written correctly**

Read back `modules/terminal.nix` and confirm it matches.

**Step 3: Commit**

```bash
git add modules/terminal.nix
git commit -m "feat: add modules/terminal.nix with WezTerm and JetBrains Mono NF"
```

---

### Task 2: Update home.nix

**Files:**
- Modify: `home.nix`

**Step 1: Write the updated file**

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

### Task 3: Activate and verify

**Step 1: Switch**

```bash
home-manager switch --flake .#me
```

If it fails with "existing file would be clobbered", move conflicting files out of the way:

```bash
mv ~/.wezterm.lua ~/.wezterm.lua.pre-hm 2>/dev/null
mv ~/.config/wezterm/wezterm.lua ~/.config/wezterm/wezterm.lua.pre-hm 2>/dev/null
home-manager switch --flake .#me
```

Expected: activation completes without errors.

**Step 2: Open WezTerm**

Launch WezTerm from Spotlight or Applications. Verify:
- Font renders correctly (JetBrains Mono, Nerd Font glyphs visible)
- Theme matches system appearance (Tokyo Night dark / Tokyo Night Day light)
- Toggle macOS dark/light mode (System Settings → Appearance) — WezTerm should switch theme live

**Step 3: Commit flake.lock if updated**

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

- WezTerm's built-in Tokyo Night theme names are exactly `Tokyo Night` (dark) and `Tokyo Night Day` (light).
- The `window-config-reloaded` event handler makes WezTerm respond to live OS appearance changes without restarting.
- Font path `share/fonts/truetype/NerdFonts/JetBrainsMono` confirmed present in `pkgs.nerd-fonts.jetbrains-mono`.
- Font name WezTerm expects: `JetBrainsMono Nerd Font Mono` (monospaced variant).
