{ lib, pkgs, config, ... }:
{
  options.my.rider = {
    enable = lib.mkEnableOption "JetBrains Rider and Gateway";
  };

  config = lib.mkIf config.my.rider.enable {
    # Auto-enable dotnet when rider is enabled
    my.dotnet.enable = lib.mkDefault true;

    home.packages = with pkgs; [
      jetbrains.rider     # Local Rider IDE
      jetbrains.gateway   # Thin client for SSH remote Rider sessions
    ];
  };
}
