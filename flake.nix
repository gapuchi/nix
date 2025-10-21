{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }: 
    let
      hostConfigs = {
        "gapuchi-desktop" = {
          stateVersion = "23.05";
          includeGuiPkgs = true;
          homeDirectory = "/home/gapuchi";
        };
      };

      forAllHosts = nixpkgs.lib.genAttrs (builtins.attrNames hostConfigs);
   in {
    nixosConfigurations = forAllHosts (hostName: nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./machines/${hostName}/configuration.nix
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.gapuchi = import ./common/home.nix;
          home-manager.extraSpecialArgs = hostConfigs.${hostName};
        }
      ];
    });

    homeConfigurations = {
      "gapuchi@gapuchi-air" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        extraSpecialArgs = {
          stateVersion = "25.05";
          includeGuiPkgs = false;
          homeDirectory = "/Users/gapuchi";
        };
        modules = [ 
          ./common/home.nix
          {
            nixpkgs.config.allowUnfree = true;
          }
        ];
      };
    };
  };
}
