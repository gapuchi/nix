{ pkgs, ... }:
{
  services.plex = {
    enable = true;
    openFirewall = true;
  };

  services.tautulli = {
    enable = true;
  };
}
