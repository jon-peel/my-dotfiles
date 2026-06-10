{ config, lib, pkgs, ... }:

{
  options.my.tailscale = {
    enable = lib.mkEnableOption "Tailscale VPN";
  };

  config = lib.mkIf config.my.tailscale.enable {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };

  };
}
