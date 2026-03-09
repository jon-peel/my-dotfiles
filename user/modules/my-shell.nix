{ config, lib, ... }:

{
  options.my.shell = {
    enable = lib.mkEnableOption "shell config";
  };

  config = lib.mkIf config.my.shell.enable {
    programs.bash.sessionVariables = {
      PATH = "$HOME/.npm-global/bin:$HOME/.aspire/bin:$PATH";
    };
  };
}
