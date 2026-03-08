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
          ./hosts/gapuchi-desktop/configuration.nix
          home-manager.nixosModules.home-manager.home-manager {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.gapuchi = import ./home/gapuchi/linux.nix;
          }
        ];
      };
    };

    homeConfigurations = {
      "gapuchi" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [ 
          ./home/gapuchi/mac.nix
          {
            nixpkgs.config.allowUnfree = true;
          }
        ];
      };
    };
  };
}
