{ config, pkgs, lib, dotfilesDir, ... }:

{
  options.my.claude = {
    enable = lib.mkEnableOption "claude code config";
  };

  config = lib.mkIf config.my.claude.enable {
    home.packages = with pkgs; [
      claude-code
      nodejs_24
      uv
    ];

    home.file.".claude/system-prompts" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/claude/system-prompts";
    };
  };
}
