{ config, lib, pkgs, ... }:

{
  options.my.i3 = {
    enable = lib.mkEnableOption "i3 tiling window manager session for xrdp";
  };

  config = lib.mkIf config.my.i3.enable {
    services.xserver = {
      enable = true;
      windowManager.i3.enable = true;
    };

    services.xrdp.defaultWindowManager =
      let
        startScript = pkgs.writeShellScript "xrdp-i3-session" ''
          # Force X11 backend
          export GDK_BACKEND=x11
          export QT_QPA_PLATFORM=xcb
          unset WAYLAND_DISPLAY
          unset WAYLAND_SOCKET

          exec ${pkgs.i3}/bin/i3
        '';
      in
        "${startScript}";
  };
}
