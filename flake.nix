{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix.url = "github:ryantm/agenix";
    mafia-bot.url = "github:gapuchi/mafia-bot-rust";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-stable,
      home-manager,
      mafia-bot,
      agenix,
      ...
    }:
    let
      username = "gapuchi";
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
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

      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [ just ];
      };
    };
}
