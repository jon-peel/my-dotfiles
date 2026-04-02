{ config, pkgs, ... }:

{
  imports = [
    ./modules/my-shell.nix
    ./modules/my-claude.nix
    ./modules/my-emacs.nix
    ./modules/my-r.nix
    ./modules/my-xfce-cde.nix
    ./modules/my-dotnet.nix
    ./modules/my-rider.nix
    ./modules/my-i3.nix
    ./modules/my-docker.nix
    ./modules/my-git.nix
    ./modules/my-browser.nix
    ./modules/my-theme-burning-amber.nix
    ./modules/my-media.nix
    ./modules/my-sysmon.nix
  ];

  home.username = "me";
  home.homeDirectory = "/home/me";

  my.shell.enable = true;
  my.claude.enable = true;
  my.emacs.enable = true;
  my.r.enable = true;
  my.i3.enable = true;
  my.xfce.cde.enable = true;
  my.rider.enable = true;
  my.docker.enable = true;
  my.git.enable = true;
  my.browser.enable = true;
  my.theme.burningAmber.enable = true;
  my.media.enable = true;
  my.sysmon.enable = true;

  programs.bash.enable = true;

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  home.stateVersion = "25.11";
}
