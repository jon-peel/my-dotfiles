{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/my-rdp.nix
    ./modules/my-xfce.nix
    ./modules/my-i3.nix
    ./modules/my-docker.nix
  ];



  # Bootloader.
  
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = false;
      timeout = 5;
    };

    kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];

  # Use latest kernel.
    kernelPackages = pkgs.linuxPackages; # _latest;
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
    networkmanager= {
      enable = true;
      dns = "none"; 
    };
  };

  #my.rdp.enable = true;
  #my.docker.enable = true;
  my.i3.enable = true;

  #wsl.enable = true;
  #wsl.defaultUser = "nixos";

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };


  # Allow nixos user to run nixos-rebuild
  nix.settings.trusted-users = [ "root" "nixos" ];

  environment.systemPackages = with pkgs; [
    git
    vim
   wget
   #tailscale
   distrobox

   windowmaker
dockapps.wmsystemtray
dockapps.wmsm-app
dockapps.wmcube
dockapps.AlsaMixer-app  
dockapps.wmCalClock
dockapps.cputnik

gnustep-gui
gworkspace


  ];

  programs.nix-ld.enable = true;
  time.timeZone = "Europe/Moscow";
  # Select internationalisation properties.
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

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

virtualisation = { 
  libvirtd.enable = true;
  podman = {
    enable = true;
    dockerCompat = true;
  };
};

programs.virt-manager.enable = true;

services.tailscale = {
  enable = true;
  # extraSetFlags = ["--netfilter-mode=nodivert"];
};

#services.tailscale.extraUpFlags = ["--operator-group=users"];
#services.tailscale.useRoutingFeatures = "server";
networking.firewall = {
  enable = true;
  # Trust the virtual bridge
  trustedInterfaces = [ "virbr0" ];
  # This is the "magic" fix for many VM networking issues on NixOS:
  checkReversePath = "loose"; 
};



 # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.me = {
    isNormalUser = true;
    description = "Jonathan Peel";
    extraGroups = [ "networkmanager" "wheel" "libvirtd"  "libvirt" "qemu-libvirtd" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;



services.tlp = {
  enable = true;
  settings = {
    # Start charging when the battery drops below 60%
    START_CHARGE_THRESH_BAT0 = 40; 
    # Stop charging when it reaches 80%
    STOP_CHARGE_THRESH_BAT0 = 60; 
  };
};


programs.steam = {
  enable = true;
  remotePlay.openFirewall = true;
  dedicatedServer.openFirewall = true;
};


# Nvida
 # 1. Enable graphics (replaces hardware.opengl in recent NixOS versions)
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Recommended for Steam/gaming
  };

  # 2. Tell NixOS to use the Nvidia driver
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    powerManagement.enable = true;
  
    # Modesetting is required for most modern features/Wayland
    modesetting.enable = true;

    # Nvidia power management (optional, can help with sleep issues)
  #  powerManagement.enable = false;

    # Use the NVidia open source kernel module (not to be confused with nouveau)
    # Recommended for Turing (RTX 20-series) or newer
    open = false;

    # Enable the Nvidia settings menu
    nvidiaSettings = true;

    # Optionally, select the appropriate driver version for your specific GPU
  # package = config.boot.kernelPackages.nvidiaPackages.stable;
      prime = {
      # Enable offload mode
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      # Replace these with the IDs from Step 1
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };

};



  system.stateVersion = "25.11";
}
