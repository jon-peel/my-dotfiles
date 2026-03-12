{ pkgs, ... }: {

  home.username = "me";
  home.homeDirectory = "/Users/me";
  home.stateVersion = "24.11";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

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

}
