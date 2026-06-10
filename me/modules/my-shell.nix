{ config, lib, pkgs, dotfilesDir, ... }:

{
  options.my.shell = {
    enable = lib.mkEnableOption "zsh shell with Starship prompt";
  };

  config = lib.mkIf config.my.shell.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        ll = "ls -lh --color=auto";
        la = "ls -lAh --color=auto";
      };

      sessionVariables = {
        PATH = "$HOME/.npm-global/bin:$HOME/.aspire/bin:$PATH";
      };

      initContent = ''
        eval "$(${pkgs.starship}/bin/starship init zsh)"
      '';
    };

    home.packages = [ pkgs.starship pkgs.tmux ];
  };
}
