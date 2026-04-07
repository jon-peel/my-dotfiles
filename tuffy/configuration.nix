{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/my-rdp.nix
    ./modules/my-xfce.nix
    ./modules/my-i3.nix
    ./modules/my-docker.nix
    ./modules/my-nvidia.nix
    ./modules/my-audio.nix
    ./modules/my-printing.nix
    ./modules/my-battery.nix
    ./modules/my-steam.nix
    ./modules/my-virt.nix
    ./modules/my-tailscale.nix
    ./modules/my-windowmaker.nix
  ];

  # Bootloader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = false;
      timeout = 5;
    };
    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  networking = {
    hostName = "tuffy";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    networkmanager = {
      enable = true;
      dns = "none";
    };
  };

  #my.rdp.enable = true;
  #my.docker.enable = true;
  my.i3.enable = true;
  my.nvidia.enable = true;
  my.audio.enable = true;
  my.printing.enable = true;
  my.battery.enable = true;
  my.steam.enable = true;
  my.virt.enable = true;
  my.tailscale.enable = true;
  my.windowmaker.enable = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "me" ];
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    distrobox
deskflow 
  ];

  #services.deskflow.client = {
  #  enable = true;
  #  server = "192.168.0.13";
  #};
  networking.firewall.allowedTCPPorts = [ 24800 ];
  networking.firewall.allowedUDPPorts = [ 24800 ];



  programs.nix-ld.enable = true;

  # xscreensaver needs setuid to prevent OOM killer unlocking the screen
  security.wrappers.xscreensaver-auth = {
    source = "${pkgs.xscreensaver}/libexec/xscreensaver/xscreensaver-auth";
    setuid = true;
    owner  = "root";
    group  = "root";
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

  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.mate.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  users.users.me = {
    isNormalUser = true;
    description = "Jonathan Peel";
    extraGroups = [ "video" "audio" "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  programs.firefox.enable = true;

  system.stateVersion = "25.11";
}
