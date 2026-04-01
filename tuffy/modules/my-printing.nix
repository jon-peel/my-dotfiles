{ config, lib, ... }:

{
  options.my.printing = {
    enable = lib.mkEnableOption "CUPS printing";
  };

  config = lib.mkIf config.my.printing.enable {
    services.printing.enable = true;
  };
}
