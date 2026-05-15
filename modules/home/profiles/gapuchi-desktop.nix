{ config, ... }:
let
  hmMods = config.flake.modules.homeManager;
in
{
  flake.modules.homeManager.gapuchiDesktop = {
    imports = with hmMods; [
      gapuchiServer
      ghostty
      vscode
    ];
  };
}
