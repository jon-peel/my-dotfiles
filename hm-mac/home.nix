{ ... }: {

  imports = [
    ./modules/git.nix
    ./modules/nix-apps.nix
    ./modules/shell.nix
    ./modules/terminal.nix
  ];

  home.username = "me";
  home.homeDirectory = "/Users/me";
  home.stateVersion = "24.11";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  my.git.enable = true;
  my.nixApps.enable = true;
  my.shell.enable = false;
  my.terminal.enable = true;

}
