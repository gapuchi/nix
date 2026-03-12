{ pkgs, ... }:
{
  imports = [ ./common.nix ];

  my.home = {
    homeDirectory = "/home/gapuchi";
  };
}
