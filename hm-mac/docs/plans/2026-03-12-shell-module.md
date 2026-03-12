# Shell Module Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create `modules/shell.nix` providing zsh with vim mode, tab completions, syntax highlighting, history suggestions, and a verbose Starship prompt with a house icon for `~`.

**Architecture:** Same pattern as `modules/git.nix` — a custom `my.shell.enable` option wrapping `programs.zsh` and `programs.starship`. Imported in `home.nix` alongside the git module.

**Tech Stack:** Nix Home Manager, zsh, Starship (nixpkgs-unstable)

---

### Task 1: Create modules/shell.nix

**Files:**
- Create: `modules/shell.nix`

**Step 1: Write the file**

```nix
{ config, lib, ... }:

{
  options.my.shell.enable = lib.mkEnableOption "zsh shell with Starship prompt";

  config = lib.mkIf config.my.shell.enable {

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      defaultKeymap = "viins";
    };

    programs.starship = {
      enable = true;
      settings = {
        add_newline = true;

        directory = {
          truncation_length = 3;
          truncate_to_repo = false;
          home_symbol = " ";
        };

        # Prompt character — changes shape in vim normal mode
        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[❯](bold red)";
          vicmd_symbol = "[❮](bold yellow)";
        };

        git_branch = {
          symbol = " ";
        };

        git_status = {
          ahead = "⇡\${count}";
          behind = "⇣\${count}";
          diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
          staged = "[+\${count}](green)";
          modified = "[!\${count}](yellow)";
          untracked = "[?\${count}](blue)";
          deleted = "[✘\${count}](red)";
        };

        cmd_duration = {
          min_time = 2000;
          format = "took [$duration](bold yellow) ";
        };

        # Show exit code on failure (disabled by default in Starship)
        status = {
          disabled = false;
          symbol = "✗ ";
        };
      };
    };

  };
}
```

**Step 2: Verify the file was written correctly**

Read back `modules/shell.nix` and confirm the content matches exactly.

**Step 3: Commit**

```bash
git add modules/shell.nix
git commit -m "feat: add modules/shell.nix with zsh and Starship"
```

---

### Task 2: Update home.nix

**Files:**
- Modify: `home.nix`

**Step 1: Add the import and enable the module**

Replace the contents of `home.nix` with:

```nix
{ ... }: {

  imports = [
    ./modules/git.nix
    ./modules/shell.nix
  ];

  home.username = "me";
  home.homeDirectory = "/Users/me";
  home.stateVersion = "24.11";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  my.git.enable = true;
  my.shell.enable = true;

}
```

**Step 2: Verify the file**

Read back `home.nix` and confirm both imports are present and both `my.*.enable` lines are set.

**Step 3: Commit**

```bash
git add home.nix
git commit -m "feat: enable shell module in home.nix"
```

---

### Task 3: Activate and verify

**Step 1: Switch**

```bash
home-manager switch --flake .#me
```

Expected: activation completes without errors.

**Step 2: Open a new terminal and verify zsh is the shell**

```bash
echo $SHELL
```

Expected: `/etc/profiles/per-user/me/bin/zsh` or `/run/current-system/sw/bin/zsh` or similar nix store path.

**Step 3: Verify Starship is running**

```bash
echo $STARSHIP_SHELL
```

Expected: `zsh`

**Step 4: Verify vim mode**

Press `esc` at the zsh prompt — the prompt character should change from `❯` (green) to `❮` (yellow). Press `i` to return to insert mode.

**Step 5: Verify tab completion**

```bash
git ch<TAB>
```

Expected: completion menu showing `checkout`, `cherry-pick`, etc.

**Step 6: Commit flake.lock if updated**

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

- The Nerd Font house glyph ( ) in `home_symbol` requires a Nerd Font in the terminal. If it renders as a box, replace with `🏠` in `modules/shell.nix` and re-run `home-manager switch --flake .#me`.
- `defaultKeymap = "viins"` sets insert mode as default — the shell behaves normally until you press `esc`.
- Language version modules (node, python, rust, etc.) are enabled by default in Starship and will appear automatically when you `cd` into a relevant project.
