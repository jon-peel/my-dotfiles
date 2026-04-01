{ config, lib, ... }:

{
  options.my.audio = {
    enable = lib.mkEnableOption "Pipewire audio stack";
  };

  config = lib.mkIf config.my.audio.enable {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
