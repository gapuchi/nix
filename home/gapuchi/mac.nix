{ pkgs, ... }:
{
  imports = [ ./common.nix ];

  my.home = {
    homeDirectory = "/Users/gapuchi";
  };
}
