{ config, lib, pkgs, ... }:

{
  options.my.windowmaker = {
    enable = lib.mkEnableOption "WindowMaker desktop and GNUstep dockapps";
  };

  config = lib.mkIf config.my.windowmaker.enable {
    environment.systemPackages = with pkgs; [
      windowmaker
      dockapps.wmsystemtray
      dockapps.wmsm-app
      dockapps.wmcube
      dockapps.AlsaMixer-app
      dockapps.wmCalClock
      dockapps.cputnik
      gnustep-gui
      gworkspace
    ];
  };
}
