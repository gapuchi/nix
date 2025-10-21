{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      "gapuchi-desktop" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./machines/gapuchi-desktop/configuration.nix
          home-manager.nixosModules.home-manager.home-manager {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.gapuchi = import ./common/home.nix;
            extraSpecialArgs = {
              stateVersion = "23.05";
              includeGuiPkgs = true;
              homeDirectory = "/home/gapuchi";
            };
          }
        ];
      };
    };

    homeConfigurations = {
      "gapuchi@gapuchi-air" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [ 
          ./common/home.nix
          {
            nixpkgs.config.allowUnfree = true;
          }
        ];
        extraSpecialArgs = {
          stateVersion = "25.05";
          includeGuiPkgs = false;
          homeDirectory = "/Users/gapuchi";
        };
      };
    };
  };
}
