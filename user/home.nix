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
  ];

  home.username = "nixos";
  home.homeDirectory = "/home/nixos";

  my.shell.enable = true;
  my.claude.enable = true;
  my.emacs.enable = true;
  my.r.enable = true;
  my.i3.enable = true;
  my.xfce.cde.enable = true;
  my.rider.enable = true;
  my.docker.enable = true;

  home.packages = with pkgs; [
    btop
    htop
  ];

  programs.firefox.enable = true;

  programs.bash.enable = true;

  # dconf D-Bus service is unavailable in WSL — disable to prevent activation failure
  dconf.enable = false;

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  home.stateVersion = "25.05";
}
