{ config, lib, ... }:

{
  options.my.battery = {
    enable = lib.mkEnableOption "TLP battery charge management";
  };

  config = lib.mkIf config.my.battery.enable {
    services.tlp = {
      enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0 = 40;
        STOP_CHARGE_THRESH_BAT0 = 60;
      };
    };
  };
}
