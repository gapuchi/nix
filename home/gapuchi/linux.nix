{ pkgs, ... }: {
    imports = [ ./common.nix, ./desktop-env.nix ];

    my.home = {
        homeDirectory = "/home/gapuchi";
    };
}