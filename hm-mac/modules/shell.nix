{ config, lib, ... }:

{
  options.my.shell.enable = lib.mkEnableOption "zsh shell with Starship prompt";

  config = lib.mkIf config.my.shell.enable {

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      defaultKeymap = "viins";
    };

    programs.starship = {
      enable = true;
      settings = {
        add_newline = true;

        directory = {
          truncation_length = 3;
          truncate_to_repo = false;
          home_symbol = " ";
        };

        # Prompt character — changes shape in vim normal mode
        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[❯](bold red)";
          vicmd_symbol = "[❮](bold yellow)";
        };

        git_branch = {
          symbol = " ";
        };

        git_status = {
          ahead = "⇡\${count}";
          behind = "⇣\${count}";
          diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
          staged = "[+\${count}](green)";
          modified = "[!\${count}](yellow)";
          untracked = "[?\${count}](blue)";
          deleted = "[✘\${count}](red)";
        };

        cmd_duration = {
          min_time = 2000;
          format = "took [$duration](bold yellow) ";
        };

        # Show exit code on failure (disabled by default in Starship)
        status = {
          disabled = false;
          symbol = "✗ ";
        };
      };
    };

  };
}
