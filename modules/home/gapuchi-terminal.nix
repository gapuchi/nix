{ config, ... }:
let
  hmMods = config.flake.modules.homeManager;
in
{
  flake.modules.homeManager.gapuchiTerminal = {
    imports = with hmMods; [
      base
      direnv
      eza
      git
      vim
      zsh
    ];
  };
}
