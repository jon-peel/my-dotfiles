{ config, lib, pkgs, ... }:

{
  options.my.sysmon = {
    enable = lib.mkEnableOption "system monitoring tools";
  };

  config = lib.mkIf config.my.sysmon.enable {
    home.packages = with pkgs; [
      btop
      htop
      killall
    ];
  };
}
