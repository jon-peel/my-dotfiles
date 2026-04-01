{ config, lib, ... }:

{
  options.my.rdp = {
    enable = lib.mkEnableOption "RDP server";
  };

  config = lib.mkIf config.my.rdp.enable {
    services.xrdp = {
      enable = true;
      port = 3390;
      openFirewall = true;
    };

    # xrdp manages its own sessions; no display manager needed
    services.displayManager.autoLogin.enable = lib.mkForce false;
  };
}
