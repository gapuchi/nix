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
      gapuchiBase
      gapuchiDefaults
      {
        my.darwin = {
          hostName = "tintin";
          homeImports = with hmMods; [ gapuchiTerminal ];
        };

        system = {
          configurationRevision = inputs.self.rev or inputs.self.dirtyRev;
          darwinLabel = inputs.self.rev or inputs.self.dirtyRev;
        };
      }
    ];
  };
}
