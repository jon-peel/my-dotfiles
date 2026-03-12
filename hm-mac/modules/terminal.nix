{ config, lib, pkgs, ... }:

{
  options.my.terminal.enable = lib.mkEnableOption "WezTerm terminal with JetBrains Mono Nerd Font";

  config = lib.mkIf config.my.terminal.enable {

    # Install font and make it visible to macOS font system
    home.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

    home.file."Library/Fonts/JetBrainsMonoNF" = {
      source = "${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype/NerdFonts/JetBrainsMono";
      recursive = true;
    };

    programs.wezterm = {
      enable = true;
      extraConfig = ''
        local wezterm = require 'wezterm'
        local config = wezterm.config_builder()

        config.font = wezterm.font 'JetBrainsMono Nerd Font Mono'
        config.font_size = 12.0

        -- Automatic dark/light theme based on macOS appearance
        local function scheme_for_appearance(appearance)
          if appearance:find 'Dark' then
            return 'Tokyo Night'
          else
            return 'Tokyo Night Day'
          end
        end

        config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())

        wezterm.on('window-config-reloaded', function(window)
          local overrides = window:get_config_overrides() or {}
          local appearance = window:get_appearance()
          local scheme = scheme_for_appearance(appearance)
          if overrides.color_scheme ~= scheme then
            overrides.color_scheme = scheme
            window:set_config_overrides(overrides)
          end
        end)

        return config
      '';
    };

  };
}
