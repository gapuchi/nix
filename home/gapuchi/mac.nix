{ pkgs, ... }:
{
  imports = [ ./common.nix ];

  my.home = {
    homeDirectory = "/Users/gapuchi";
    stateVersion = "25.05";
  };
}
