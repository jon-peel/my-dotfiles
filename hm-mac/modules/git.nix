{ config, lib, ... }:

{
  options.my.git.enable = lib.mkEnableOption "git and gh configuration";

  config = lib.mkIf config.my.git.enable {

    programs.git = {
      enable = true;
      settings = {
        user.name = "Jonathan Peel";
        user.email = "me@jonathanpeel.co.za";
        init.defaultBranch = "main";
        pull.rebase = true;
      };
    };

    programs.gh = {
      enable = true;
    };

  };
}
