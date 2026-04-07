{ config, lib, pkgs, dotfilesDir, ... }:

let
  cfg = config.my.theme.crt;

  # ── Picom GLSL shaders ─────────────────────────────────────────────────────

  darkScanlineGlsl = ''
    #version 130

    uniform sampler2D tex;
    uniform float     opacity;
    in vec2           texcoord;

    vec4 default_post_processing(vec4 c);

    // ── Tuning ────────────────────────────────────────────────────────────
    const float SCANLINE_DARK     = 0.72;
    const float VIGNETTE_STRENGTH = 1.1;
    const float CA_OFFSET         = 0.00075;
    const float GLOW_STRENGTH     = 0.25;
    const float GLOW_RADIUS       = 3.0;

    vec4 window_shader() {
        vec2 texSize = vec2(textureSize(tex, 0));
        vec2 uv      = texcoord / texSize;

        // ── Chromatic aberration ──────────────────────────────────────────
        float r = texture2D(tex, vec2(uv.x - CA_OFFSET, uv.y)).r;
        float g = texture2D(tex, uv).g;
        float b = texture2D(tex, vec2(uv.x + CA_OFFSET, uv.y)).b;
        vec4  c = vec4(r, g, b, texture2D(tex, uv).a);

        // ── Phosphor glow ─────────────────────────────────────────────────
        vec2 px   = GLOW_RADIUS / texSize;
        vec4 blur = vec4(0.0);
        blur += texture2D(tex, uv + vec2(-px.x,  0.0 )) * 0.20;
        blur += texture2D(tex, uv + vec2( px.x,  0.0 )) * 0.20;
        blur += texture2D(tex, uv + vec2( 0.0,  -px.y)) * 0.20;
        blur += texture2D(tex, uv + vec2( 0.0,   px.y)) * 0.20;
        blur += texture2D(tex, uv + vec2(-px.x, -px.y)) * 0.05;
        blur += texture2D(tex, uv + vec2( px.x, -px.y)) * 0.05;
        blur += texture2D(tex, uv + vec2(-px.x,  px.y)) * 0.05;
        blur += texture2D(tex, uv + vec2( px.x,  px.y)) * 0.05;
        float lum      = dot(blur.rgb, vec3(0.299, 0.587, 0.114));
        float glowMask = smoothstep(0.3, 0.9, lum);
        vec3  amber    = vec3(1.0, 0.69, 0.0);
        c.rgb += blur.rgb * amber * glowMask * GLOW_STRENGTH;
        c.rgb  = clamp(c.rgb, 0.0, 1.0);

        // ── Scanlines ─────────────────────────────────────────────────────
        c.rgb *= mix(SCANLINE_DARK, 1.0, mod(floor(gl_FragCoord.y), 2.0));

        // ── Vignette ──────────────────────────────────────────────────────
        vec2  v = uv - 0.5;
        c.rgb  *= clamp(1.0 - dot(v, v) * VIGNETTE_STRENGTH, 0.0, 1.0);

        return default_post_processing(c);
    }
  '';

  lightScanlineGlsl = ''
    #version 130

    uniform sampler2D tex;
    uniform float     opacity;
    in vec2           texcoord;

    vec4 default_post_processing(vec4 c);

    // ── Tuning ────────────────────────────────────────────────────────────
    const float SCANLINE_DARK     = 0.88;
    const float VIGNETTE_STRENGTH = 0.4;

    vec4 window_shader() {
        vec2 texSize = vec2(textureSize(tex, 0));
        vec2 uv      = texcoord / texSize;

        vec4 c = texture2D(tex, uv);

        // ── Scanlines ─────────────────────────────────────────────────────
        c.rgb *= mix(SCANLINE_DARK, 1.0, mod(floor(gl_FragCoord.y), 2.0));

        // ── Vignette ──────────────────────────────────────────────────────
        vec2  v = uv - 0.5;
        c.rgb  *= clamp(1.0 - dot(v, v) * VIGNETTE_STRENGTH, 0.0, 1.0);

        return default_post_processing(c);
    }
  '';

  # ── i3 colour variable blocks ───────────────────────────────────────────────

  darkI3Colors = ''
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

    # client.* must live in the same included file as the set vars —
    # i3 does not substitute include-defined vars into client.* in other files
    #                         border    background  text     indicator  child_border
    client.focused            $blue     $blue       $base    $lavender  $blue
    client.focused_inactive   $overlay  $surface    $text    $overlay   $overlay
    client.unfocused          $overlay  $base       $subtext $overlay   $overlay
    client.urgent             $red      $red        $base    $red       $red

    bar {
      position top
      i3bar_command i3bar --transparency
      status_command i3status-rs ~/.config/crt-themes/dark/i3status-rust.toml
      font pango:BlexMono Nerd Font Mono 9
      separator_symbol "░"

      colors {
        background         #0D0800B0
        statusline         #FFB000
        separator          #3D2400

        #                    border    background  text
        focused_workspace    #FFB000   #FFB000     #0D0800
        active_workspace     #1A0F00   #1A0F00     #FFB000
        inactive_workspace   #1A0F00   #1A0F00     #FFB000
        urgent_workspace     #FF4400   #FF4400     #0D0800
      }
    }
  '';

  lightI3Colors = ''
    set $base     #D8EDD8
    set $surface  #C8DCC8
    set $overlay  #557755
    set $text     #1A3520
    set $subtext  #3D6040
    set $blue     #007700
    set $lavender #009900
    set $green    #005500
    set $red      #AA2200
    set $yellow   #007700
    set $base_bar #557755B0

    #                         border    background  text     indicator  child_border
    client.focused            $blue     $blue       $base    $lavender  $blue
    client.focused_inactive   $overlay  $surface    $text    $overlay   $overlay
    client.unfocused          $overlay  $base       $subtext $overlay   $overlay
    client.urgent             $red      $red        $base    $red       $red

    bar {
      position top
      i3bar_command i3bar --transparency
      status_command i3status-rs ~/.config/crt-themes/light/i3status-rust.toml
      font pango:BlexMono Nerd Font Mono 9
      separator_symbol "░"

      colors {
        background         #557755B0
        statusline         #1A3520
        separator          #557755

        #                    border    background  text
        focused_workspace    #007700   #007700     #D8EDD8
        active_workspace     #C8DCC8   #C8DCC8     #1A3520
        inactive_workspace   #C8DCC8   #C8DCC8     #1A3520
        urgent_workspace     #AA2200   #AA2200     #D8EDD8
      }
    }
  '';

  # ── Alacritty colour themes ─────────────────────────────────────────────────

  darkAlacrittyTheme = ''
    # Burning Amber CRT — Alacritty colour theme

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
    black   = "#1A0F00"
    red     = "#CC2200"
    green   = "#886600"
    yellow  = "#FF8800"
    blue    = "#FF5500"
    magenta = "#993300"
    cyan    = "#FFAA00"
    white   = "#CC9900"

    [colors.bright]
    black   = "#3D2400"
    red     = "#FF3300"
    green   = "#CCAA00"
    yellow  = "#FFD060"
    blue    = "#FF7700"
    magenta = "#FF5500"
    cyan    = "#FFB84D"
    white   = "#FFE680"
  '';

  lightAlacrittyTheme = ''
    # Phosphor Overexposed — Alacritty colour theme

    [colors.primary]
    background = "#D8EDD8"
    foreground = "#1A3520"

    [colors.cursor]
    text   = "#D8EDD8"
    cursor = "#007700"

    [colors.selection]
    text       = "#D8EDD8"
    background = "#007700"

    [colors.normal]
    black   = "#B8CEB8"
    red     = "#AA2200"
    green   = "#005500"
    yellow  = "#557700"
    blue    = "#007700"
    magenta = "#336633"
    cyan    = "#009900"
    white   = "#2A5030"

    [colors.bright]
    black   = "#C8DEC8"
    red     = "#CC3300"
    green   = "#007700"
    yellow  = "#889900"
    blue    = "#009900"
    magenta = "#558855"
    cyan    = "#00BB00"
    white   = "#1A3520"
  '';

  # ── i3status-rust shared block definitions ──────────────────────────────────

  i3statusBlocks = ''
    [icons]
    icons = "material-nf"

    [[block]]
    block = "custom"
    command = 'current=$(cat ~/.config/crt-themes/current 2>/dev/null || echo dark); [ "$current" = dark ] && echo "🌙 dark" || echo "☀ light"'
    interval = 60
    hide_when_empty = false
    [[block.click]]
    button = "left"
    cmd = 'if [ "$(cat ~/.config/crt-themes/current 2>/dev/null)" = dark ]; then ~/.nix-profile/bin/theme-switch light; else ~/.nix-profile/bin/theme-switch dark; fi'

    [[block]]
    block = "cpu"
    format = " CPU $barchart $utilization "
    interval = 5
    [[block.click]]
    button = "left"
    cmd = "alacritty -e htop -s PERCENT_CPU"

    [[block]]
    block = "memory"
    format = " MEM $mem_used "
    interval = 5
    [[block.click]]
    button = "left"
    cmd = "alacritty -e htop -s PERCENT_MEM"

    [[block]]
    block = "disk_space"
    path = "/"
    [[block.click]]
    button = "left"
    cmd = "alacritty -e ncdu /"

    [[block]]
    block = "net"
    device = "wlo1"
    format = " $icon $ssid $signal_strength "
    interval = 5
    [[block.click]]
    button = "left"
    cmd = "alacritty -e nmtui"

    [[block]]
    block = "net"
    format = " ↑ $speed_up.eng(prefix:K) ↓ $speed_down.eng(prefix:K) "
    interval = 5

    [[block]]
    block = "sound"
    driver = "pulseaudio"
    [[block.click]]
    button = "left"
    cmd = "alacritty -e pulsemixer"

    [[block]]
    block = "battery"
    format = " BAT $percentage "
    interval = 30
    [[block.click]]
    button = "left"
    cmd = "alacritty -e sudo powertop"

    [[block]]
    block = "time"
    format = " $timestamp.datetime(f:'%H:%M:%S') "
    interval = 1
    [[block.click]]
    button = "left"
    cmd = "alacritty -e calcurse"
  '';

  darkI3statusRust = ''
    [theme]
    theme = "plain"

    [theme.overrides]
    idle_bg      = "#0D0800"
    idle_fg      = "#FFB000"
    info_bg      = "#0D0800"
    info_fg      = "#FFC940"
    good_bg      = "#0D0800"
    good_fg      = "#CC8800"
    warning_bg   = "#1A0F00"
    warning_fg   = "#FF6600"
    critical_bg  = "#FF4400"
    critical_fg  = "#0D0800"
    separator     = "░"
    separator_bg  = "#0D0800"
    separator_fg  = "#A67C52"

  '' + i3statusBlocks;

  lightI3statusRust = ''
    [theme]
    theme = "plain"

    [theme.overrides]
    idle_bg      = "#D8EDD8"
    idle_fg      = "#1A3520"
    info_bg      = "#D8EDD8"
    info_fg      = "#007700"
    good_bg      = "#D8EDD8"
    good_fg      = "#005500"
    warning_bg   = "#C8DCC8"
    warning_fg   = "#886600"
    critical_bg  = "#AA2200"
    critical_fg  = "#D8EDD8"
    separator     = "░"
    separator_bg  = "#D8EDD8"
    separator_fg  = "#557755"

  '' + i3statusBlocks;

  # ── GTK 3 CSS ───────────────────────────────────────────────────────────────

  darkGtk3Css = ''
    /* ── Burning Amber CRT — Windows-style GTK3 override ───────────────── */

    * { border-radius: 0 !important; }

    @define-color scanlines_bg #0D0800;

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

    entry {
      background: #050200;
      color: #FFB000;
      border: 2px solid;
      border-color: #080400 #4D3000 #4D3000 #080400;
      caret-color: #FF6600;
    }
    entry:focus { border-color: #FF8800 #3D2400 #3D2400 #FF8800; }
    entry:disabled { color: #4D3000; background: #0A0600; }

    *:selected, selection {
      background-color: #FF8800;
      color: #0D0800;
    }

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

    tooltip {
      background: #1A1000;
      color: #FFB000;
      border: 1px solid #FF8800;
    }

    progressbar trough {
      background: #050200;
      border: 2px solid;
      border-color: #080400 #4D3000 #4D3000 #080400;
    }
    progressbar progress { background: #FF8800; }

    check, radio {
      background: #050200;
      border: 2px solid;
      border-color: #080400 #4D3000 #4D3000 #080400;
      color: #FF8800;
    }

    statusbar {
      background: #1A1000;
      color: #CC8800;
      border-top: 1px solid #3D2400;
    }

    frame > border, .frame {
      border: 2px solid;
      border-color: #080400 #4D3000 #4D3000 #080400;
    }
  '';

  lightGtk3Css = ''
    /* ── Phosphor Overexposed — GTK3 override ──────────────────────────── */

    * { border-radius: 0 !important; }

    window, .background {
      background-color: #D8EDD8;
      color: #1A3520;
    }

    headerbar {
      background-color: #B8D0B8;
      color: #1A3520;
      border-bottom: 2px solid #557755;
      box-shadow: none;
    }
    headerbar:backdrop {
      background: #C8DCC8;
      color: #557755;
      border-bottom-color: #AADDAA;
    }
    headerbar .title { color: #1A3520; font-weight: bold; }
    headerbar .subtitle { color: #3D6040; }

    button {
      background: #AADDAA;
      color: #1A3520;
      border: 2px solid #007700;
      box-shadow: none;
      text-shadow: none;
      padding: 3px 10px;
    }
    button:hover {
      background: #C8DCC8;
      color: #005500;
      border-color: #005500;
    }
    button:active, button:checked {
      background: #AADDAA;
      color: #007700;
      border-color: #007700;
    }
    button:disabled { color: #557755; background: #C8DCC8; border-color: #AADDAA; }

    menubar, .menubar {
      background: #C8DCC8;
      color: #1A3520;
      border-bottom: 1px solid #557755;
    }
    menubar > menuitem:hover {
      background: #007700;
      color: #D8EDD8;
    }
    menu, .menu, .context-menu {
      background: #C8DCC8;
      color: #1A3520;
      border: 2px solid;
      border-color: #AADDAA #557755 #557755 #AADDAA;
    }
    menuitem:hover, menuitem:selected {
      background: #007700;
      color: #D8EDD8;
    }
    menuitem:disabled { color: #557755; }
    separator { background: #557755; min-height: 1px; margin: 2px 0; }

    textview, textview text {
      background-color: #D8EDD8;
      color: #1A3520;
    }

    entry {
      background: #E8F4E8;
      color: #1A3520;
      border: 2px solid;
      border-color: #557755 #AADDAA #AADDAA #557755;
      caret-color: #007700;
    }
    entry:focus { border-color: #007700 #AADDAA #AADDAA #007700; }
    entry:disabled { color: #557755; background: #C8DCC8; }

    *:selected, selection {
      background-color: #007700;
      color: #D8EDD8;
    }

    scrollbar { background: #C8DCC8; border: 1px solid #557755; }
    scrollbar slider {
      background: #557755;
      border: 2px solid;
      border-color: #AADDAA #3D6040 #3D6040 #AADDAA;
      min-width: 14px;
      min-height: 14px;
    }
    scrollbar slider:hover { background: #3D6040; }
    scrollbar button {
      background: #C8DCC8;
      color: #1A3520;
      border: 1px solid #557755;
      min-width: 14px;
      min-height: 14px;
    }

    treeview {
      background-color: #D8EDD8;
      color: #1A3520;
    }
    treeview:selected { background: #007700; color: #D8EDD8; }
    treeview:nth-child(even) { background-color: #CDE7CD; }
    treeview header button {
      background: #C8DCC8;
      color: #3D6040;
      border: 1px solid #557755;
    }

    notebook tab {
      background: #C8DCC8;
      color: #557755;
      border: 1px solid #AADDAA;
      padding: 4px 14px;
    }
    notebook tab:checked {
      background: #D8EDD8;
      color: #1A3520;
    }

    tooltip {
      background: #C8DCC8;
      color: #1A3520;
      border: 1px solid #007700;
    }

    progressbar trough {
      background: #E8F4E8;
      border: 2px solid;
      border-color: #557755 #AADDAA #AADDAA #557755;
    }
    progressbar progress { background: #007700; }

    check, radio {
      background: #E8F4E8;
      border: 2px solid;
      border-color: #557755 #AADDAA #AADDAA #557755;
      color: #007700;
    }

    statusbar {
      background: #C8DCC8;
      color: #3D6040;
      border-top: 1px solid #557755;
    }

    frame > border, .frame {
      border: 2px solid;
      border-color: #557755 #AADDAA #AADDAA #557755;
    }
  '';

  # ── GTK 4 CSS ───────────────────────────────────────────────────────────────

  darkGtk4Css = ''
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

  lightGtk4Css = ''
    /* ── Phosphor Overexposed — GTK4 override ──────────────────────────── */
    * { border-radius: 0; }
    window, .background {
      background-color: #D8EDD8;
      color: #1A3520;
    }
    headerbar {
      background: linear-gradient(to bottom, #B8D0B8, #C8DCC8);
      color: #1A3520;
      border-bottom: 2px solid #557755;
    }
    button {
      background: #AADDAA;
      color: #1A3520;
      border: 2px solid #007700;
    }
    button:hover { background: #C8DCC8; color: #005500; border-color: #005500; }
    button:active { color: #007700; border-color: #007700; }
    entry {
      background: #E8F4E8;
      color: #1A3520;
      border: 2px solid;
      border-color: #557755 #AADDAA #AADDAA #557755;
    }
    *:selected { background-color: #007700; color: #D8EDD8; }
  '';

  # ── theme-switch script ─────────────────────────────────────────────────────

  themeSwitchScript = pkgs.writeShellScriptBin "theme-switch" ''
    set -euo pipefail
    # Ensure system bins are reachable when called from i3status-rust's
    # minimal click-handler environment (i3-msg, gsettings, etc.)
    export PATH="/run/current-system/sw/bin:$HOME/.nix-profile/bin:$PATH"

    VARIANT="''${1:-}"
    THEMES="$HOME/.config/crt-themes"

    if [[ "$VARIANT" != "dark" && "$VARIANT" != "light" ]]; then
      echo "Usage: theme-switch dark|light" >&2
      exit 1
    fi

    # 1. Swap the active symlink
    ln -sfn "$THEMES/$VARIANT" "$THEMES/active"
    echo "$VARIANT" > "$THEMES/current"

    # 2. Reload i3 — re-parses includes (new i3-colors) and restarts exec_always
    #    Click handlers run with minimal env (no DISPLAY/I3SOCK), so find the
    #    i3 IPC socket directly by path rather than relying on env var discovery.
    I3SOCK=$(ls /run/user/$(id -u)/i3/ipc-socket.* 2>/dev/null | head -1)
    if [[ -n "$I3SOCK" ]]; then
      i3-msg -s "$I3SOCK" reload 2>/dev/null || true
    fi

    # 3. i3status-rust — i3-msg reload causes i3 to restart i3bar (bar config
    #    has new hex colours), which restarts the status_command automatically.
    #    No explicit pkill needed — it races with i3bar's own restart.

    # 4. GTK colour-scheme preference (browsers + GTK apps query this)
    if [[ "$VARIANT" == "light" ]]; then
      gsettings set org.gnome.desktop.interface color-scheme 'prefer-light' 2>/dev/null || true
      gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'         2>/dev/null || true
    else
      gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'  2>/dev/null || true
      gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'    2>/dev/null || true
    fi

    # 5. GTK CSS — write active variant's CSS (persists across home-manager switch
    #    because activation script re-applies from the saved 'current' variant)
    mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
    # GTK3 CSS (live-switchable — Nix does not manage gtk-3.0/gtk.css)
    cp -f "$THEMES/active/gtk3.css" "$HOME/.config/gtk-3.0/gtk.css" 2>/dev/null || true
    # GTK4 CSS stays as Nix dark default; gsettings color-scheme handles
    # dark/light preference for GTK4 apps at runtime

    # 6. Alacritty live reload — write to a plain file that inotify watches
    #    (importing a symlink target only gets resolved at startup; a real file
    #    triggers reload in all running Alacritty windows automatically)
    cp -f "$THEMES/active/alacritty-theme.toml" \
          "$HOME/.config/alacritty/live-theme.toml" 2>/dev/null || true

    # 7. Wallpaper — set explicitly here so it is not subject to exec_always
    #    timing relative to i3bar restart during reload
    if [[ -n "''${DISPLAY:-}" ]]; then
      feh --bg-fill "$THEMES/active/wallpaper.png" 2>/dev/null || true
    fi

    echo "Switched to $VARIANT theme."
  '';

in
{
  options.my.theme.crt = {
    enable = lib.mkEnableOption "CRT dual theme (Burning Amber dark / Phosphor Green light)";
    picom = lib.mkOption {
      type        = lib.types.bool;
      default     = true;
      description = "Enable picom compositor with CRT scanline shader.";
    };
    wallpaper = lib.mkOption {
      type        = lib.types.bool;
      default     = true;
      description = "Set theme wallpaper via feh.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [

    # ── Always-on ────────────────────────────────────────────────────────────
    {
      # ── Dark theme files ───────────────────────────────────────────────────
      home.file.".config/crt-themes/dark/i3-colors".text         = darkI3Colors;
      home.file.".config/crt-themes/dark/alacritty-theme.toml".text = darkAlacrittyTheme;
      home.file.".config/crt-themes/dark/i3status-rust.toml".text   = darkI3statusRust;
      home.file.".config/crt-themes/dark/gtk3.css".text             = darkGtk3Css;
      home.file.".config/crt-themes/dark/gtk4.css".text             = darkGtk4Css;
      home.file.".config/crt-themes/dark/starship.toml" = {
        source = config.lib.file.mkOutOfStoreSymlink
          "${dotfilesDir}/themes/burning-amber/starship.toml";
      };
      home.file.".config/crt-themes/dark/conky.conf" = {
        source = config.lib.file.mkOutOfStoreSymlink
          "${dotfilesDir}/themes/burning-amber/conky.conf";
      };
      home.file.".config/crt-themes/dark/doom-theme.el" = {
        source = config.lib.file.mkOutOfStoreSymlink
          "${dotfilesDir}/themes/burning-amber/doom-theme.el";
      };
      home.file.".config/crt-themes/dark/wallpaper.png" = {
        source = config.lib.file.mkOutOfStoreSymlink
          "${dotfilesDir}/themes/burning-amber/scanlines.png";
      };
      home.file.".config/crt-themes/dark/scanline.glsl".text = darkScanlineGlsl;

      # ── Light theme files ──────────────────────────────────────────────────
      home.file.".config/crt-themes/light/i3-colors".text          = lightI3Colors;
      home.file.".config/crt-themes/light/alacritty-theme.toml".text = lightAlacrittyTheme;
      home.file.".config/crt-themes/light/i3status-rust.toml".text   = lightI3statusRust;
      home.file.".config/crt-themes/light/gtk3.css".text             = lightGtk3Css;
      home.file.".config/crt-themes/light/gtk4.css".text             = lightGtk4Css;
      home.file.".config/crt-themes/light/starship.toml" = {
        source = config.lib.file.mkOutOfStoreSymlink
          "${dotfilesDir}/themes/phosphor-green/starship.toml";
      };
      home.file.".config/crt-themes/light/conky.conf" = {
        source = config.lib.file.mkOutOfStoreSymlink
          "${dotfilesDir}/themes/phosphor-green/conky.conf";
      };
      home.file.".config/crt-themes/light/doom-theme.el" = {
        source = config.lib.file.mkOutOfStoreSymlink
          "${dotfilesDir}/themes/phosphor-green/doom-theme.el";
      };
      home.file.".config/crt-themes/light/wallpaper.png" = {
        source = config.lib.file.mkOutOfStoreSymlink
          "${dotfilesDir}/themes/phosphor-green/scanlines.png";
      };
      home.file.".config/crt-themes/light/scanline.glsl".text = lightScanlineGlsl;

      # ── i3 config stub (colour vars injected via include) ──────────────────
      home.file.".config/i3/config".text = ''
        # CRT theme stub — colour variables injected from active theme
        include ~/.config/crt-themes/active/i3-colors

        include ~/.config/i3/config.base

        ${lib.optionalString cfg.wallpaper ''
          exec_always --no-startup-id feh --bg-fill ~/.config/crt-themes/active/wallpaper.png
        ''}
        ${lib.optionalString cfg.picom ''
          exec_always --no-startup-id killall -q picom; sleep 0.3 && picom --config ~/.config/picom/picom.conf -b
        ''}
        exec --no-startup-id xscreensaver -no-splash
      '';

      # ── Doom Emacs loader stub ─────────────────────────────────────────────
      home.file.".doom-theme.el".text = ''
        ;; CRT theme loader — managed by my-theme-crt.nix, do not edit manually
        (load-file (expand-file-name "~/.config/crt-themes/active/doom-theme.el"))
      '';

      # ── Starship — resolved via STARSHIP_CONFIG env var ────────────────────
      home.sessionVariables.STARSHIP_CONFIG =
        "${config.home.homeDirectory}/.config/crt-themes/active/starship.toml";

      # ── Cursor ────────────────────────────────────────────────────────────
      home.pointerCursor = {
        package    = pkgs.vanilla-dmz;
        name       = "DMZ-Black";
        size       = 24;
        gtk.enable = true;
        x11.enable = true;
      };

      # ── GTK — font, theme, GTK4 CSS (dark default, Nix-managed) ──────────
      # GTK3 CSS is written by the activation script + theme-switch (live-
      # switchable). GTK4 CSS stays as a Nix-managed dark default; GTK4 apps
      # use gsettings color-scheme for dark/light preference at runtime.
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
        gtk4.extraCss = darkGtk4Css;
      };

      # ── theme-switch script ────────────────────────────────────────────────
      home.packages = [ themeSwitchScript ];

      # ── xscreensaver ──────────────────────────────────────────────────────
      home.file.".xscreensaver-notwork".text = ''
        timeout:        0:10:00
        lock:           True
        lockTimeout:    0:00:00
        passwdTimeout:  0:00:30
        fade:           True
        fadeSeconds:    0:00:03
        fadeTicks:      20
        splash:         False
        mode:           one
        selected:       0

        programs: \
            matrix -root \n\

        *matrix.color:          #FFB000
        *matrix.background:     #000000
        *matrix.delay:          25000
        *matrix.density:        25
        *matrix.speed:          1.0
      '';

      # ── Activation: initialise active symlink + GTK CSS + i3status config ──
      home.activation."crt-theme-init" =
        lib.hm.dag.entryAfter [ "linkGeneration" ] ''
          THEMES="$HOME/.config/crt-themes"

          # Initialise active → dark on first install
          if [[ ! -L "$THEMES/active" ]]; then
            ln -sfn "$THEMES/dark" "$THEMES/active"
            echo "dark" > "$THEMES/current"
          fi

          # Re-apply GTK CSS for whichever variant is current (persists through
          # home-manager switch without needing to re-run theme-switch)
          CURRENT=$(cat "$THEMES/current" 2>/dev/null || echo "dark")
          mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
          cp -f "$THEMES/$CURRENT/gtk3.css" "$HOME/.config/gtk-3.0/gtk.css" || true
          mkdir -p "$HOME/.config/alacritty"
          cp -f "$THEMES/$CURRENT/alacritty-theme.toml" \
                "$HOME/.config/alacritty/live-theme.toml" || true

          # i3status-rust: ensure config.toml points through active/
          # (survives the i3status-rust directory → file migration in my-i3.nix)
          mkdir -p "$HOME/.config/i3status-rust"
          ln -sf "$THEMES/active/i3status-rust.toml" \
                 "$HOME/.config/i3status-rust/config.toml"
        '';
    }

    # ── Wallpaper (optional) ─────────────────────────────────────────────────
    (lib.mkIf cfg.wallpaper {
      home.packages = [ pkgs.feh ];
    })

    # ── Picom compositor + CRT shaders (optional) ────────────────────────────
    (lib.mkIf cfg.picom {
      home.packages = [ pkgs.picom ];

      home.file.".config/picom/picom.conf".text = ''
        backend     = "glx";
        vsync       = true;
        glx-no-stencil      = true;
        glx-copy-from-front = false;

        window-shader-fg = "${config.home.homeDirectory}/.config/crt-themes/active/scanline.glsl";

        window-shader-fg-rule = [
          "${config.home.homeDirectory}/.config/picom/passthrough.glsl:class_g = 'vlc'",
          "${config.home.homeDirectory}/.config/picom/passthrough.glsl:class_g = '.virt-manager-wrapped'",
          "${config.home.homeDirectory}/.config/picom/passthrough.glsl:_NET_WM_STATE@:32a *= '_NET_WM_STATE_FULLSCREEN'"
        ];

        shadow = false;
        fading = false;
      '';

      # scanline.glsl lives in each theme directory (dark/light) and is
      # symlinked through active/ — picom.conf points there directly.

      home.file.".config/picom/passthrough.glsl".text = ''
        #version 130

        uniform sampler2D tex;
        uniform float     opacity;
        in vec2           texcoord;

        vec4 default_post_processing(vec4 c);

        vec4 window_shader() {
            vec2 uv = texcoord / vec2(textureSize(tex, 0));
            return default_post_processing(texture2D(tex, uv));
        }
      '';
    })

  ]);
}
