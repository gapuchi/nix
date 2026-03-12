{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      username = "gapuchi";
    in
    {
      nixosConfigurations = {
        "gapuchi-desktop" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/gapuchi-desktop/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.gapuchi = import ./home/${username}/linux.nix;
            }
          ];
        };
        "calculus" = nixpkgs.lib.nixosSystem {
          modules = [
            ./hosts/calculus/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.gapuchi = import ./home/${username}/linux-headless.nix;
            }
          ];
        };
      };

      homeConfigurations = {
        "${username}@tintin" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          modules = [
            ./home/${username}/mac.nix
            {
              nixpkgs.config.allowUnfree = true;
            }
          ];
        };
      };
    };
}
