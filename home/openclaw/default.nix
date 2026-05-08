{ lib, osConfig, ... }:
{
  imports = [
    ./openclaw.nix
  ];

  home = {
    username = "openclaw";
    homeDirectory = "/var/lib/openclaw";
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
}
