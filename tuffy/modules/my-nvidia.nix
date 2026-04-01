{ config, lib, pkgs, ... }:

{
  options.my.nvidia = {
    enable = lib.mkEnableOption "Nvidia GPU with Intel Prime offload";
  };

  config = lib.mkIf config.my.nvidia.enable {
    boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];
    boot.kernelPackages = pkgs.linuxPackages;

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      powerManagement.enable = true;
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };
}
