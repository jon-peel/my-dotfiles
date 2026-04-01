{ config, pkgs, lib, dotfilesDir, ... }:

{
  options.my.emacs = {
    enable = lib.mkEnableOption "emacs with doom config";
  };

  config = lib.mkIf config.my.emacs.enable {
    home.packages = with pkgs; [
      emacs
      fd                          # file finder used by Doom for file search
      ripgrep                     # rg binary used by Doom for text search
      shellcheck                  # shell script linting
      multimarkdown               # markdown compiler for markdown-preview
      symbola                     # Symbola font (unicode symbols/emoji)
      nerd-fonts.symbols-only     # Symbols Nerd Font Mono
      jetbrains-mono              # monospace font for Emacs
    ];

    fonts.fontconfig.enable = true;

    home.file.".config/doom" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/doom";
    };
  };
}
