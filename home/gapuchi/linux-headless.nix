{ pkgs, ... }:
{
  imports = [
    ./common.nix
    ./modules/openclaw.nix
  ];

  my.home = {
    homeDirectory = "/home/gapuchi";
  };
}
