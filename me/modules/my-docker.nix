{ config, lib, pkgs, ... }:

{
  options.my.docker = {
    enable = lib.mkEnableOption "Docker CLI tools";
  };

  config = lib.mkIf config.my.docker.enable {
    home.packages = with pkgs; [
      docker-compose
      lazydocker
    ];
  };
}
