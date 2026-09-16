{ config, ... }:
let
  hmMods = config.flake.modules.homeManager;
in
{
  flake.modules.homeManager.gapuchiDesktop =
    { pkgs, ... }:
    {
      imports = with hmMods; [
        ghostty
        cursor
      ];

      home.packages = with pkgs; [
        _1password-gui
        beeper
        discord
        firefox
        google-chrome
        plex-desktop
        signal-desktop
        spotify
      ];
    };
}
