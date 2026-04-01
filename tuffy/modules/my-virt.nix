{ config, lib, ... }:

{
  options.my.virt = {
    enable = lib.mkEnableOption "libvirt virtualisation and podman";
  };

  config = lib.mkIf config.my.virt.enable {
    virtualisation.libvirtd.enable = true;
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
    };
    programs.virt-manager.enable = true;
    users.users.me.extraGroups = [ "libvirtd" "libvirt" "qemu-libvirtd" ];
    networking.firewall = {
      trustedInterfaces = [ "virbr0" ];
      checkReversePath = "loose";
    };
  };
}
