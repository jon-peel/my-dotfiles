{ config, lib, pkgs, ... }:

{
  options.my.xfce = {
    enable = lib.mkEnableOption "XFCE desktop session for xrdp";
  };

  config = lib.mkIf config.my.xfce.enable {
    services.xserver = {
      enable = true;
      desktopManager.xfce.enable = true;
    };

    services.xrdp.defaultWindowManager =
      let
        startScript = pkgs.writeShellScript "xrdp-xfce-session" ''
          # Force X11 backend — prevents XFCE 4.20 from probing Wayland protocols
          export GDK_BACKEND=x11
          export QT_QPA_PLATFORM=xcb
          unset WAYLAND_DISPLAY
          unset WAYLAND_SOCKET

          # Disable xfwm4 compositor, which causes a black screen under xrdp
          ${pkgs.xfce.xfconf}/bin/xfconf-query \
            -c xfwm4 -p /general/use_compositing -s false 2>/dev/null || true

          exec ${pkgs.xfce.xfce4-session}/bin/startxfce4
        '';
      in
        "${startScript}";
  };
}
