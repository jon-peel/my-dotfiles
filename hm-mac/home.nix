{ ... }: {

  imports = [
    ./modules/git.nix
    ./modules/shell.nix
    ./modules/terminal.nix
  ];

  home.username = "me";
  home.homeDirectory = "/Users/me";
  home.stateVersion = "24.11";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  my.git.enable = true;
  my.shell.enable = true;
  my.terminal.enable = true;

}
