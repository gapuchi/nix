{ ... }:
{
  flake.modules.nixos.caddy =
    { pkgs, config, ... }:
    let
      # Wildcard cert for *.lab.adhia.net via Let's Encrypt DNS-01 (Cloudflare).
      tls = ''
        tls {
          dns cloudflare {env.CF_API_TOKEN}
        }
      '';
    in
    {
      services.caddy = {
        enable = true;
        package = pkgs.caddy.withPlugins {
          plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
          hash = "sha256-bzMqxWTqrJ1skZmRTXyEMCKStXpljbqe5r0Ve2cnBfM=";
        };
        virtualHosts = {
          "plex.lab.adhia.net".extraConfig = ''
            reverse_proxy localhost:32400
            ${tls}
          '';
          "uptime-kuma.lab.adhia.net".extraConfig = ''
            reverse_proxy localhost:3001
            ${tls}
          '';
          "pihole.lab.adhia.net".extraConfig = ''
            reverse_proxy localhost:8080
            ${tls}
          '';
          "netdata.lab.adhia.net".extraConfig = ''
            reverse_proxy localhost:19999
            ${tls}
          '';
        };
      };

      # Cloudflare API token (Zone:DNS:Edit on adhia.net) as `CF_API_TOKEN=...`.
      age.secrets.caddy-dns-token.file = ../../secrets/caddy-dns-token.age;
      systemd.services.caddy.serviceConfig.EnvironmentFile = config.age.secrets.caddy-dns-token.path;

      # 80/443 are only reachable over Tailscale.
      networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
        80
        443
      ];
    };
}
