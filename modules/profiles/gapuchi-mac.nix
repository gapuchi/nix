{ inputs, config, ... }:

let
  hmMods = config.flake.modules.homeManager;
in
{
  flake.homeConfigurations."gapuchi@tintin" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
    modules = with hmMods; [
      gapuchiDesktop
      {
        nixpkgs.config.allowUnfree = true;
        my.home.homeDirectory = "/Users/gapuchi";
      }
    ];
  };
}
