{ config, lib, pkgs, dotfilesDir, ... }:

{
  options.my.i3 = {
    enable = lib.mkEnableOption "i3 config symlink";
  };

  config = lib.mkIf config.my.i3.enable {
    home.packages = with pkgs; [
      alacritty        # terminal — reliable under xrdp
      i3status-rust    # status bar backend
      dmenu            # app launcher (Mod+d)
      nerd-fonts.blex-mono       # IBM Plex Mono + Nerd Font icons
      conky            # keybinding overlay
      xdotool          # lower conky window below all others
    ];

    fonts.fontconfig.enable = true;

    home.file.".config/i3/config.base" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/i3/config";
    };

    home.file.".config/alacritty/alacritty.toml" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/alacritty/alacritty.toml";
    };

    home.file.".config/i3status-rust" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/i3status-rust";
    };

  };
}
