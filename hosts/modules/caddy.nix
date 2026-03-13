{ config, pkgs, ... }:

{
  services.caddy = {
    enable = true;
    virtualHosts = {
      "plex.home.arpa" = {
        extraConfig = "
            reverse_proxy localhost:32400
            tls internal
          ";
      };
      "tautulli.home.arpa" = {
        extraConfig = "
            reverse_proxy localhost:8181
            tls internal
          ";
      };
      "uptime-kuma.home.arpa" = {
        extraConfig = "
            reverse_proxy localhost:3001
            tls internal
          ";
      };
      "pihole.home.arpa" = {
        extraConfig = "
            reverse_proxy localhost:8080
            tls internal
          ";
      };
      "grafana.home.arpa" = {
        extraConfig = "
            reverse_proxy localhost:3000
            tls internal
          ";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
