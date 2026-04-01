{ config, lib, ... }:

{
  options.my.steam = {
    enable = lib.mkEnableOption "Steam gaming platform";
  };

  config = lib.mkIf config.my.steam.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
  };
}
