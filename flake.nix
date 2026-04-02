{
  description = "NixOS system and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code-overlay = {
      url = "github:ryoppippi/claude-code-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, claude-code-overlay, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ claude-code-overlay.overlays.default ];
      };
    in {
      nixosConfigurations.tuffy = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          ./tuffy/configuration.nix
          { environment.systemPackages = [ home-manager.packages.${system}.default ]; }
        ];
      };

      homeConfigurations.me = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./me/home.nix ];
        extraSpecialArgs = { dotfilesDir = "/home/me/dotfiles/dotfiles"; };
      };
    };
}
