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
      nerd-fonts.jetbrains-mono  # icons in the bar
    ];

    fonts.fontconfig.enable = true;

    home.file.".config/i3" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/i3";
    };

    home.file.".config/alacritty" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/alacritty";
    };

    home.file.".config/i3status-rust" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/i3status-rust";
    };
  };
}
