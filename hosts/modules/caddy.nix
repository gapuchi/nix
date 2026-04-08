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
      "openclaw.home.arpa" = {
        extraConfig = "
            reverse_proxy localhost:3002
            tls internal
          ";
      };
    };
  };

  # 80/443 are only reachable over Tailscale. Nothing is exposed on the WAN
  # or LAN interface — clients (including on-LAN ones) hit Caddy via the
  # server's Tailscale IP. Backends remain bound to 127.0.0.1 via the
  # reverse_proxy targets above.
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    80
    443
  ];
}
