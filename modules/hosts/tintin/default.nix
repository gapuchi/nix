{ inputs, config, ... }:

let
  darwinMods = config.flake.modules.darwin;
  hmMods = config.flake.modules.homeManager;
in
{
  flake.darwinConfigurations.tintin = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = { inherit inputs; };
    modules = with darwinMods; [
      base
      gapuchiDefaults
      inputs.home-manager.darwinModules.home-manager
      {
        my.darwin = {
          hostName = "tintin";
          homeImports = with hmMods; [
            gapuchiTerminal
            ghostty
          ];
        };

        system = {
          configurationRevision = inputs.self.rev or inputs.self.dirtyRev;
          darwinLabel = inputs.self.rev or inputs.self.dirtyRev;
        };
      }
    ];
  };
}
