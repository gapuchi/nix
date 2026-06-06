{ inputs, config, ... }:
let
  darwinMods = config.flake.modules.darwin;
in
{
  flake.modules.darwin.gapuchiBase = {
    imports =
      with darwinMods;
      [ base ]
      ++ [
        inputs.home-manager.darwinModules.home-manager
      ];
  };
}
