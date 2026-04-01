{ config, lib, pkgs, ... }:

{
  options.my.media = {
    enable = lib.mkEnableOption "media and security applications";
  };

  config = lib.mkIf config.my.media.enable {
    home.packages = with pkgs; [
      vlc
      veracrypt
    ];
  };
}
