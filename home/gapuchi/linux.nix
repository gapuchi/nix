{ pkgs, ... }: {
    imports = [ ./common.nix ];

    my.home = {
        homeDirectory = "/home/gapuchi";
        stateVersion = "23.05";
    };


    # TODO Validate this
    home.packages = home.packages ++ with pkgs; [
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