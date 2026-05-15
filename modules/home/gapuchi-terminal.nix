{ config, ... }:
let
  hmMods = config.flake.modules.homeManager;
in
{
  flake.modules.homeManager.gapuchiTerminal = {
    imports = with hmMods; [
      base
      direnv
      git
      vim
      zsh
    ];
  };
}
