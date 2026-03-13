{ config, pkgs, ... }:

{
  services.caddy =
    let
      # As configured in Tailscale
      machine = "calculus";
      tailnet = "bone-triceratops.ts.net";
    in
    {
      enable = true;
      virtualHosts = {
        "pihole.${machine}.${tailnet}".extraConfig = ''
          reverse_proxy localhost:8080
        '';

        "plex.${machine}.${tailnet}".extraConfig = ''
          reverse_proxy localhost:32400
        '';

        "kuma.${machine}.${tailnet}".extraConfig = ''
          reverse_proxy localhost:3001
        '';

        "tautulli.${machine}.${tailnet}".extraConfig = ''
          reverse_proxy localhost:8181
        '';
      };
    };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
