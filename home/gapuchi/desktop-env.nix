{ pkgs, ... }:
{
  home.packages = with pkgs; [
    _1password-gui
    beeper
    code-cursor
    discord
    firefox
    google-chrome
    plex-desktop
    signal-desktop
    spotify
  ];
}
