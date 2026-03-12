# hm-mac

Home Manager configuration for macOS.

## Prerequisites

### Install Nix

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Open a new terminal after install. If `nix` is not on your PATH, source it manually:

```bash
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

## First-time activation

The `-b backup` flag backs up any existing config files that Home Manager wants to manage:

```bash
nix run github:nix-community/home-manager -- switch -b backup --flake .#me
```

## Updating

After the first activation, `home-manager` is on your PATH. Apply any config changes with:

```bash
home-manager switch --flake .#me
```
