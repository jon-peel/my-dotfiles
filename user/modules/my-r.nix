{ config, pkgs, lib, ... }:

{
  options.my.r = {
    enable = lib.mkEnableOption "R language environment";
  };

  config = lib.mkIf config.my.r.enable {
    home.packages = [
      (pkgs.rWrapper.override {
        packages = with pkgs.rPackages; [ tidyverse patchwork ];
      })
    ];
  };
}
