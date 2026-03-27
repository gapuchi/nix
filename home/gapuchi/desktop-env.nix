{ pkgs, ... }:
{
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
}
