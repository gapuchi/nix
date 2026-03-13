{ pkgs, ... }:
{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    permitCertUid = "caddy";
  };
}
