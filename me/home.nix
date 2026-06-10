{ config, pkgs, lib, hostname, ... }:

let
  isTuffy = hostname == "tuffy";
in
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
    ./modules/my-theme-crt.nix
    ./modules/my-media.nix
    ./modules/my-sysmon.nix
  ];

  home.username = "me";
  home.homeDirectory = "/home/me";

  my.shell.enable = true;
  my.emacs.enable = true;
  my.git.enable = true;
  my.docker.enable = true;
  my.claude.enable = true;

  my.r.enable = isTuffy;
  my.i3.enable = isTuffy;
  my.xfce.cde.enable = isTuffy;
  my.rider.enable = isTuffy;
  my.browser.enable = isTuffy;
  my.theme.crt.enable = isTuffy;
  my.media.enable = isTuffy;
  my.sysmon.enable = isTuffy;

  programs.bash.enable = true;

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  home.stateVersion = "25.11";
}
