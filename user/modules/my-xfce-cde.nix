{ config, pkgs, lib, ... }:

{
  options.my.xfce.cde = {
    enable = lib.mkEnableOption "CDE/Motif theme for XFCE";
  };

  config = lib.mkIf config.my.xfce.cde.enable {
    gtk = {
      enable = true;
      iconTheme = {
        name = "gnome";
        package = pkgs.gnome-icon-theme;
      };
      theme = {
        name = "cdetheme";
        package = pkgs.stdenv.mkDerivation {
          pname = "cde-motif-theme";
          version = "unstable-2022-12-18";
          src = pkgs.fetchFromGitHub {
            owner = "josvanr";
            repo = "cde-motif-theme";
            rev = "149074e6c69c53d8528aa024f723c830557ad85f";
            sha256 = "11qaq2g8i0iky6gz33bbr4i7kkivyxns3s5jig0sfjzv7znb2f1y";
          };
          dontBuild = true;
          installPhase = ''
            mkdir -p $out/share/themes
            cp -r cdetheme $out/share/themes
          '';
        };
      };
    };

    # xfce4-panel is NOT managed via xfconf.settings — doing so would generate a
    # channel XML with only our keys, wiping all plugin-ids and reverting the panel
    # to bare defaults.  Instead, patch just the specific properties we care about
    # against the live xfconfd at activation time.  xfconfd then persists the
    # changes to its own XML, leaving all plugin config untouched.
    home.activation.xfcePanelCde = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      xq="${pkgs.xfce.xfconf}/bin/xfconf-query"
      $xq -c xfwm4 -p /general/theme --create -t string -s cdetheme 2>/dev/null || true
      if $xq -c xfce4-panel -p /panels > /dev/null 2>&1; then
        $xq -c xfce4-panel -p /panels/dark-mode                 --create -t bool   -s false
        $xq -c xfce4-panel -p /panels/panel-2/autohide-behavior --create -t int    -s 0
        $xq -c xfce4-panel -p /panels/panel-2/length            --create -t int    -s 60
        _sh=$(${pkgs.xorg.xrandr}/bin/xrandr --current 2>/dev/null \
              | awk '/ \*/{split($1,a,"x"); print a[2]; exit}')
        _y=$(( ''${_sh:-1080} - 48 ))
        $xq -c xfce4-panel -p /panels/panel-2/position          --create -t string -s "p=11;x=0;y=$_y"
      fi
    '';
  };
}
