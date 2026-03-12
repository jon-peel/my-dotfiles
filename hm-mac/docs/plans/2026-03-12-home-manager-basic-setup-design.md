# Home Manager Basic Setup — Design

## Overview

Standalone Home Manager (no nix-darwin) using a Nix flake, managing the user environment on macOS.

## File Structure

```
hm-mac/
├── flake.nix   # inputs + homeConfigurations output
└── home.nix    # user environment: git + gh
```

## Components

### flake.nix
- Inputs: `nixpkgs` (unstable), `home-manager`
- Output: `homeConfigurations."jonathan"` using `home-manager.lib.homeManagerConfiguration`

### home.nix
- `programs.git`: name = "Jonathan Peel", email = "me@jonathanpeel.co.za", sensible defaults
- `programs.gh`: enabled, installs GitHub CLI

## Activation

```sh
home-manager switch --flake .#jonathan
```

## Non-Goals

- No nix-darwin system config
- No macOS system settings
- No Homebrew management (can be added later)
