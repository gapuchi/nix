{ pkgs, ... }:
{
  services.plex = {
    enable = true;
    openFirewall = true;
    user = "gapuchi";
  };
}
