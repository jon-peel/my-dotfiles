{ lib, pkgs, config, ... }:
{
  options.my.dotnet = {
    enable = lib.mkEnableOption ".NET development environment";
  };

  config = lib.mkIf config.my.dotnet.enable {
    home.packages = with pkgs; [
      dotnetCorePackages.sdk_10_0
      omnisharp-roslyn    # C# language server (LSP)
      dotnet-ef           # Entity Framework Core CLI
      fsautocomplete      # F# language server (LSP)
      playwright          # Playwright CLI + browser drivers
      chromium            # Chromium browser for web testing
      icu                 # ICU libraries required by .NET runtime
    ];

    home.sessionVariables = {
      LD_LIBRARY_PATH = "${pkgs.icu}/lib:$LD_LIBRARY_PATH";
    };
  };
}
