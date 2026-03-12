{ pkgs, ... }: {

  home.username = "me";
  home.homeDirectory = "/Users/me";
  home.stateVersion = "24.11";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Jonathan Peel";
    userEmail = "me@jonathanpeel.co.za";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  programs.gh = {
    enable = true;
  };

}
