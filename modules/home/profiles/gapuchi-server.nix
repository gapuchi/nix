{ config, ... }:
let
  hmMods = config.flake.modules.homeManager;
in
{
  flake.modules.homeManager.gapuchiServer = {
    imports = with hmMods; [
      base
      direnv
      git
      vim
      zsh
    ];
  };
}
