{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules/my-rdp.nix
    ./modules/my-xfce.nix
    ./modules/my-i3.nix
    ./modules/my-docker.nix
  ];

  my.rdp.enable = true;
  my.docker.enable = true;
  my.i3.enable = true;

  wsl.enable = true;
  wsl.defaultUser = "nixos";

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  # Allow nixos user to run nixos-rebuild
  nix.settings.trusted-users = [ "root" "nixos" ];

  environment.systemPackages = with pkgs; [
    git
    vim
  ];

  programs.nix-ld.enable = true;
  time.timeZone = "Europe/Moscow";

  system.stateVersion = "25.05";
}
