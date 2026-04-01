{ config, lib, ... }:

{
  options.my.docker = {
    enable = lib.mkEnableOption "Docker daemon";
  };

  config = lib.mkIf config.my.docker.enable {
    virtualisation.docker.enable = true;

    users.users.me.extraGroups = [ "docker" ];
  };
}
