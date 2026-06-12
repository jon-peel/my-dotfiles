{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../tuffy/modules/my-tailscale.nix
    ../tuffy/modules/my-docker.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 5;
  };

  fileSystems."/media/white" = {
    device = "/dev/disk/by-uuid/5228-58CB";
    options = [
     "rw"
     "users" # Allows any user to mount and unmount
     "nofail" # Prevent system from failing if this drive doesn't mount
     "uid=1000" "gid=100"
     "dmask=000" "fmask=111"
   ];
  };
 

  my.tailscale.enable = true;
  my.docker.enable = true;

networking = {
    hostName = "ideapad";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    networkmanager = {
      enable = true;
      dns = "none";
    };
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "me" ];
  };

  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_ZA.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_ZA.UTF-8";
    LC_IDENTIFICATION = "en_ZA.UTF-8";
    LC_MEASUREMENT = "en_ZA.UTF-8";
    LC_MONETARY = "en_ZA.UTF-8";
    LC_NAME = "en_ZA.UTF-8";
    LC_NUMERIC = "en_ZA.UTF-8";
    LC_PAPER = "en_ZA.UTF-8";
    LC_TELEPHONE = "en_ZA.UTF-8";
    LC_TIME = "en_ZA.UTF-8";
  };

  users.users.me = {
    isNormalUser = true;
    description = "Jonathan Peel";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    mosh
  ];


  services.kmscon = {
    enable = true;
    # fonts = [ { name = "Source Code Pro"; package = pkgs.source-code-pro; } ];
    fonts = [{ name = "JetBrainsMono Nerd Font"; package = pkgs.nerd-fonts.jetbrains-mono; }];
    # fonts = [{ name = "JetBrainsMono Nerd Font"; packages = pkgs.nerd-fonts.jetbrains-mono; }];
  };


  services.logind.lidSwitchExternalPower = "ignore";
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';


  system.stateVersion = "25.11";
}
