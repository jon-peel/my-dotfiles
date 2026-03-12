# Home Manager Basic Setup — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Set up a standalone Home Manager flake on macOS managing git and gh CLI for user `me`.

**Architecture:** Nix flake with `home-manager` as a standalone tool (no nix-darwin). `flake.nix` declares inputs and a single `homeConfigurations."me"` output. `home.nix` contains all user config.

**Tech Stack:** Nix (Determinate Systems installer), home-manager, nixpkgs-unstable, aarch64-darwin

---

### Task 1: Install Nix

**Files:** none (system-level install)

**Step 1: Run the Determinate Systems installer**

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Follow the prompts. This installs Nix with flakes enabled by default.

**Step 2: Verify Nix is available (open a new terminal first)**

```bash
nix --version
```

Expected output: `nix (Nix) 2.x.x`

---

### Task 2: Create flake.nix

**Files:**
- Create: `flake.nix`

**Step 1: Create the file**

```nix
{
  description = "Home Manager configuration for me";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }: {
    homeConfigurations."me" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      modules = [ ./home.nix ];
    };
  };
}
```

**Step 2: Verify the file parses**

```bash
nix flake check
```

Expected: no errors (it will download nixpkgs on first run — this is normal and may take a few minutes)

**Step 3: Commit**

```bash
git add flake.nix
git commit -m "feat: add flake.nix for home-manager"
```

---

### Task 3: Create home.nix

**Files:**
- Create: `home.nix`

**Step 1: Create the file**

```nix
{ pkgs, ... }: {

  home.username = "me";
  home.homeDirectory = "/Users/me";
  home.stateVersion = "24.11";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Jonathan Peel";
    userEmail = "me@jonathanpeel.co.za";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  programs.gh = {
    enable = true;
  };

}
```

**Step 2: Commit**

```bash
git add home.nix
git commit -m "feat: add home.nix with git and gh config"
```

---

### Task 4: Bootstrap and activate

**Step 1: Run home-manager for the first time via nix run**

From the `hm-mac` directory:

```bash
nix run github:nix-community/home-manager -- switch --flake .#me
```

This bootstraps home-manager without needing it pre-installed. It will take a few minutes on first run as it downloads packages.

Expected: output ends with something like `Activating home-manager configuration`

**Step 2: Verify git config was applied**

```bash
git config --global user.name
git config --global user.email
```

Expected:
```
Jonathan Peel
me@jonathanpeel.co.za
```

**Step 3: Verify gh is available**

```bash
gh --version
```

Expected: `gh version x.x.x ...`

**Step 4: Commit the flake.lock**

The first run generates a `flake.lock` pinning exact dependency versions. Commit it:

```bash
git add flake.lock
git commit -m "chore: add flake.lock"
```

---

## Subsequent activations

After the initial bootstrap, activate changes with:

```bash
home-manager switch --flake .#me
```

(home-manager will be on your PATH after the first `nix run` activation)
