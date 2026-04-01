{ config, lib, pkgs, ... }:

{
  options.my.git = {
    enable = lib.mkEnableOption "git config";
  };

  config = lib.mkIf config.my.git.enable {
    home.packages = [ pkgs.gh ];

    programs.git = {
      enable = true;
      settings = {
        user.email = "me@jonathanpeel.co.za";
        user.name = "Jonathan Peel";
        credential.helper = "!gh auth git-credential";
      };
    };
  };
}
