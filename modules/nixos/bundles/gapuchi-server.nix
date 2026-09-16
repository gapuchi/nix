{ inputs, config, ... }:
let
  hmMods = config.flake.modules.homeManager;
  nixosMods = config.flake.modules.nixos;
in
{
  flake.modules.nixos.gapuchiServer =
    { pkgs, ... }:
    {
      imports =
        with nixosMods;
        [ base ]
        ++ [
          inputs.home-manager.nixosModules.home-manager
        ];

      my.nixos.homeImports = with hmMods; [ gapuchiTerminal ];

      boot.loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };

      networking.networkmanager.enable = true;

      nix = {
        settings.experimental-features = [
          "nix-command"
          "flakes"
        ];
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 30d";
        };
        optimise = {
          automatic = true;
          dates = "weekly";
        };
      };

      boot.supportedFilesystems = [ "nfs" ];

      programs.nix-ld.enable = true;

      environment.systemPackages = with pkgs; [
        git
        vim
        wget
        ghostty.terminfo
      ];
    };
}
