{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.systems.follows = "flake-utils/systems";
    };
    mafia-bot = {
      url = "github:gapuchi/mafia-bot-rust";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };
    openclaw = {
      url = "github:gapuchi/openclaw-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-stable,
      home-manager,
      mafia-bot,
      agenix,
      openclaw,
      flake-utils,
      ...
    }:
    let
      username = "gapuchi";
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {
        "gapuchi-desktop" = nixpkgs.lib.nixosSystem {
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
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.gapuchi = import ./home/${username}/linux-headless.nix;
            }
            openclaw.nixosModules.default
            { nixpkgs.overlays = [ openclaw.overlays.default ]; }
          ];
          specialArgs = {
            inherit mafia-bot;
            pkgs-stable = import nixpkgs-stable { inherit system; };
          };
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
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.git
            pkgs.just
            agenix.packages.${system}.default
          ];
        };
      }
    );
}
