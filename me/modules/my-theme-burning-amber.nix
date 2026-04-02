{ config, lib, pkgs, dotfilesDir, ... }:

{
  options.my.theme.burningAmber = {
    enable     = lib.mkEnableOption "Burning Amber CRT theme";
    picom      = lib.mkOption {
      type        = lib.types.bool;
      default     = true;
      description = "Enable picom compositor with CRT scanline shader. Set false to run without compositor.";
    };
    wallpaper  = lib.mkOption {
      type        = lib.types.bool;
      default     = true;
      description = "Set scanlines PNG as desktop wallpaper via feh.";
    };
  };

  config = lib.mkIf config.my.theme.burningAmber.enable (lib.mkMerge [

    # ── Always-on theme ──────────────────────────────────────────────────────────
    {
      home.file.".config/i3/config".text = ''
        # Burning Amber CRT — i3 colours
        set $base     #0D0800
        set $surface  #1A0F00
        set $overlay  #3D2400
        set $text     #FFB000
        set $subtext  #7A5500
        set $blue     #FFB000
        set $lavender #FFC940
        set $green    #CC8800
        set $red      #FF4400
        set $yellow   #FFB000
        set $base_bar #0D0800B0

        include ~/.config/i3/config.base

        ${lib.optionalString config.my.theme.burningAmber.wallpaper ''
          exec_always --no-startup-id feh --bg-fill ~/.config/burning-amber/scanlines.png
        ''}
        ${lib.optionalString config.my.theme.burningAmber.picom ''
          exec_always --no-startup-id killall -q picom; sleep 0.3 && picom --config ~/.config/picom/picom.conf -b
        ''}
      '';

      home.file.".config/alacritty/theme.toml".text = ''
        # Burning Amber CRT — Alacritty colour theme
        # Palette spans the full orange spectrum: deep red-orange → mid orange → hot amber

        [colors.primary]
        background = "#0D0800"
        foreground = "#FFB000"

        [colors.cursor]
        text   = "#0D0800"
        cursor = "#FF6600"

        [colors.selection]
        text       = "#0D0800"
        background = "#FF8800"

        [colors.normal]
        black   = "#1A0F00"   # deep amber-black
        red     = "#CC2200"   # deep red-orange  (errors, danger)
        green   = "#886600"   # dark burnt amber  (strings, success)
        yellow  = "#FF8800"   # mid orange        (warnings, types)
        blue    = "#FF5500"   # orange-red        (functions, dirs)
        magenta = "#993300"   # dark burnt orange (constants, special)
        cyan    = "#FFAA00"   # warm amber        (operators, info)
        white   = "#CC9900"   # muted amber       (normal text)

        [colors.bright]
        black   = "#3D2400"   # medium dark
        red     = "#FF3300"   # vivid red-orange
        green   = "#CCAA00"   # golden amber
        yellow  = "#FFD060"   # hot bright amber
        blue    = "#FF7700"   # vivid orange
        magenta = "#FF5500"   # vivid burnt orange
        cyan    = "#FFB84D"   # bright warm amber
        white   = "#FFE680"   # near-white amber
      '';

      home.file.".config/starship.toml" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/themes/burning-amber/starship.toml";
      };

      home.file.".config/conky/i3-keys.conf" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/themes/burning-amber/conky.conf";
      };

      gtk = {
        enable = true;
        font = {
          name    = "IBM Plex Mono";
          size    = 10;
          package = pkgs.ibm-plex;
        };
        theme = {
          name    = lib.mkForce "Adwaita-dark";
          package = lib.mkForce pkgs.gnome-themes-extra;
        };
        gtk3.extraCss = ''
          /* ── Burning Amber CRT — Windows-style GTK3 override ───────────────── */

          * { border-radius: 0 !important; }

          /* ── Scanline gradient (reused across large surfaces) ────────────── */
          @define-color scanlines_bg #0D0800;

          /* Base */
          window, .background {
            background-color: #0D0800;
            background-image: repeating-linear-gradient(
              to bottom,
              transparent   0px,
              transparent   3px,
              rgba(0,0,0,0.7) 3px,
              rgba(0,0,0,0.7) 5px
            );
            color: #FFB000;
          }

          /* ── Headerbar / titlebar ─────────────────────────────────────────── */
          headerbar {
            background-color: #2A1800;
            background-image: repeating-linear-gradient(
              to bottom,
              transparent   0px,
              transparent   3px,
              rgba(0,0,0,0.7) 3px,
              rgba(0,0,0,0.7) 5px
            );
            color: #FFB000;
            border-bottom: 2px solid #3D2400;
            box-shadow: none;
          }
          headerbar:backdrop {
            background: #0D0800;
            color: #7A5500;
            border-bottom-color: #1A0F00;
          }
          headerbar .title { color: #FFB000; font-weight: bold; }
          headerbar .subtitle { color: #CC8800; }

          /* ── Buttons ──────────────────────────────────────────────────────── */
          button {
            background: #000000;
            color: #FFB000;
            border: 2px solid #FF8800;
            box-shadow: none;
            text-shadow: none;
            padding: 3px 10px;
          }
          button:hover {
            background: #1A0F00;
            color: #FFC940;
            border-color: #FFC940;
          }
          button:active, button:checked {
            background: #000000;
            color: #FF6600;
            border-color: #FF6600;
          }
          button:disabled { color: #3D2400; background: #000000; border-color: #3D2400; }

          /* ── Menus ────────────────────────────────────────────────────────── */
          menubar, .menubar {
            background: #1A1000;
            color: #FFB000;
            border-bottom: 1px solid #3D2400;
          }
          menubar > menuitem:hover {
            background: #FF8800;
            color: #0D0800;
          }
          menu, .menu, .context-menu {
            background: #1A1000;
            color: #FFB000;
            border: 2px solid;
            border-color: #4D3000 #080400 #080400 #4D3000;
          }
          menuitem:hover, menuitem:selected {
            background: #FF8800;
            color: #0D0800;
          }
          menuitem:disabled { color: #4D3000; }
          separator { background: #3D2400; min-height: 1px; margin: 2px 0; }

          /* ── Text views (large content areas) ────────────────────────────── */
          textview, textview text {
            background-color: #0D0800;
            background-image: repeating-linear-gradient(
              to bottom,
              transparent   0px,
              transparent   3px,
              rgba(0,0,0,0.7) 3px,
              rgba(0,0,0,0.7) 5px
            );
            color: #FFB000;
          }

          /* ── Entries — sunken bevel ───────────────────────────────────────── */
          entry {
            background: #050200;
            color: #FFB000;
            border: 2px solid;
            border-color: #080400 #4D3000 #4D3000 #080400;
            caret-color: #FF6600;
          }
          entry:focus { border-color: #FF8800 #3D2400 #3D2400 #FF8800; }
          entry:disabled { color: #4D3000; background: #0A0600; }

          /* ── Selection ────────────────────────────────────────────────────── */
          *:selected, selection {
            background-color: #FF8800;
            color: #0D0800;
          }

          /* ── Scrollbars ───────────────────────────────────────────────────── */
          scrollbar { background: #0D0800; border: 1px solid #3D2400; }
          scrollbar slider {
            background: #3D2400;
            border: 2px solid;
            border-color: #4D3000 #080400 #080400 #4D3000;
            min-width: 14px;
            min-height: 14px;
          }
          scrollbar slider:hover { background: #5D3800; }
          scrollbar button {
            background: #1A1000;
            color: #FFB000;
            border: 1px solid #3D2400;
            min-width: 14px;
            min-height: 14px;
          }

          /* ── Lists / treeviews ────────────────────────────────────────────── */
          treeview {
            background-color: #0D0800;
            background-image: repeating-linear-gradient(
              to bottom,
              transparent   0px,
              transparent   3px,
              rgba(0,0,0,0.7) 3px,
              rgba(0,0,0,0.7) 5px
            );
            color: #FFB000;
          }
          treeview:selected { background: #FF8800; color: #0D0800; }
          treeview:nth-child(even) { background-color: #100800; }
          treeview header button {
            background: #1A1000;
            color: #CC8800;
            border: 1px solid #3D2400;
          }

          /* ── Notebook tabs ────────────────────────────────────────────────── */
          notebook tab {
            background: #0D0800;
            color: #7A5500;
            border: 1px solid #3D2400;
            padding: 4px 14px;
          }
          notebook tab:checked {
            background: #1A1000;
            color: #FFB000;
          }

          /* ── Tooltip ──────────────────────────────────────────────────────── */
          tooltip {
            background: #1A1000;
            color: #FFB000;
            border: 1px solid #FF8800;
          }

          /* ── Progress ─────────────────────────────────────────────────────── */
          progressbar trough {
            background: #050200;
            border: 2px solid;
            border-color: #080400 #4D3000 #4D3000 #080400;
          }
          progressbar progress { background: #FF8800; }

          /* ── Check / radio ────────────────────────────────────────────────── */
          check, radio {
            background: #050200;
            border: 2px solid;
            border-color: #080400 #4D3000 #4D3000 #080400;
            color: #FF8800;
          }

          /* ── Statusbar ────────────────────────────────────────────────────── */
          statusbar {
            background: #1A1000;
            color: #CC8800;
            border-top: 1px solid #3D2400;
          }

          /* ── Frames / panes ───────────────────────────────────────────────── */
          frame > border, .frame {
            border: 2px solid;
            border-color: #080400 #4D3000 #4D3000 #080400;
          }
        '';
        gtk4.extraCss = ''
          /* ── Burning Amber CRT — GTK4 override ─────────────────────────────── */
          * { border-radius: 0; }
          window, .background {
            background-color: #0D0800;
            color: #FFB000;
          }
          headerbar {
            background: linear-gradient(to bottom, #2A1800, #0D0800);
            color: #FFB000;
            border-bottom: 2px solid #3D2400;
          }
          button {
            background: #000000;
            color: #FFB000;
            border: 2px solid #FF8800;
          }
          button:hover { background: #1A0F00; color: #FFC940; border-color: #FFC940; }
          button:active { color: #FF6600; border-color: #FF6600; }
          entry {
            background: #050200;
            color: #FFB000;
            border: 2px solid;
            border-color: #080400 #4D3000 #4D3000 #080400;
          }
          *:selected { background-color: #FF8800; color: #0D0800; }
        '';
      };
    }

    # ── Scanlines wallpaper (my.theme.burningAmber.wallpaper = true) ─────────────
    (lib.mkIf config.my.theme.burningAmber.wallpaper {
      home.packages = [ pkgs.feh ];

      home.file.".config/burning-amber/scanlines.png" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/themes/burning-amber/scanlines.png";
      };
    })

    # ── Picom scanline compositor (my.theme.burningAmber.picom = true) ───────────
    (lib.mkIf config.my.theme.burningAmber.picom {
      home.packages = [ pkgs.picom ];

      home.file.".config/picom/picom.conf".text = ''
        # Picom — Burning Amber CRT compositor config
        # To disable scanlines without rebuilding: comment out window-shader-fg below.
        # To disable picom entirely:  set my.theme.burningAmber.picom = false; in home.nix

        backend     = "glx";
        vsync       = true;
        glx-no-stencil      = true;
        glx-copy-from-front = false;

        # CRT scanline shader — comment this line to run compositor without the effect
        window-shader-fg = "~/.config/picom/scanline.glsl";

        shadow = false;
        fading = false;
      '';

      home.file.".config/picom/scanline.glsl".text = ''
        #version 130

        in  vec2      texcoord;
        uniform sampler2D tex;
        uniform float     opacity;

        void main() {
            vec4  c        = texture2D(tex, texcoord);
            // Alternate rows: even rows are slightly dimmed to simulate CRT scanlines.
            // Adjust the mix ratio (0.72) to taste — lower = darker bands.
            float even     = mod(floor(gl_FragCoord.y), 2.0);
            float bright   = mix(0.72, 1.0, even);
            gl_FragColor   = vec4(c.rgb * bright, c.a * opacity);
        }
      '';
    })

  ]);
}
