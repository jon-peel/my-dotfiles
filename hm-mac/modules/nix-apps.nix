{ config, lib, ... }:

{
  options.my.nixApps.enable = lib.mkEnableOption "symlink Nix apps into ~/Applications for Spotlight";

  config = lib.mkIf config.my.nixApps.enable {

    # Symlink each .app from ~/.nix-profile/Applications/ directly into
    # ~/Applications/ so macOS Spotlight can discover them.
    home.activation.linkNixApps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$HOME/Applications"
      for app in "$HOME/.nix-profile/Applications/"*.app; do
        [ -e "$app" ] || continue
        appname=$(basename "$app")
        ln -sfn "$app" "$HOME/Applications/$appname"
      done
    '';

  };
}
