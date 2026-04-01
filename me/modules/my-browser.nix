{ config, lib, ... }:

{
  options.my.browser = {
    enable = lib.mkEnableOption "Firefox web browser";
  };

  config = lib.mkIf config.my.browser.enable {
    programs.firefox.enable = true;
  };
}
