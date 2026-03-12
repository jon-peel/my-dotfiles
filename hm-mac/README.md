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

## Activate

```bash
nix run github:nix-community/home-manager -- switch --flake .#me
```

After the first activation, `home-manager` will be on your PATH:

```bash
home-manager switch --flake .#me
```
