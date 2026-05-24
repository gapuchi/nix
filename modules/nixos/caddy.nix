{ ... }:
{
  flake.modules.nixos.caddy = {
    services.caddy = {
      enable = true;
      virtualHosts = {
        "plex.home.arpa".extraConfig = ''
          reverse_proxy localhost:32400
          tls internal
        '';
        "tautulli.home.arpa".extraConfig = ''
          reverse_proxy localhost:8181
          tls internal
        '';
        "uptime-kuma.home.arpa".extraConfig = ''
          reverse_proxy localhost:3001
          tls internal
        '';
        "pihole.home.arpa".extraConfig = ''
          reverse_proxy localhost:8080
          tls internal
        '';
        "netdata.home.arpa".extraConfig = ''
          reverse_proxy localhost:19999
          tls internal
        '';
      };
    };
    # 80/443 are only reachable over Tailscale.
    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
      80
      443
    ];
  };
}
