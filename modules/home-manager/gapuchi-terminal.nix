{ config, ... }:
let
  hmMods = config.flake.modules.homeManager;
in
{
  flake.modules.homeManager.gapuchiTerminal = {
    imports = with hmMods; [
      base
      git
      vim
      zsh
    ];

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.eza = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
