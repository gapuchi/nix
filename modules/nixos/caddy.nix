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
          hash = "sha256-dQvk6ezY6TQ1J7PjhCXnThF/SqVgPwBO8/RXzHCY+js=";
        };
        virtualHosts = {
          "home.lab.adhia.net".extraConfig = ''
            handle /calculus.jpeg {
              root * ${./assets}
              file_server
            }
            reverse_proxy localhost:8082
            ${tls}
          '';
          "plex.lab.adhia.net".extraConfig = ''
            reverse_proxy localhost:32400
            ${tls}
          '';
          "qbittorrent.lab.adhia.net".extraConfig = ''
            reverse_proxy 192.168.15.1:8090
            ${tls}
          '';
          "prowlarr.lab.adhia.net".extraConfig = ''
            reverse_proxy 127.0.0.1:9696
            ${tls}
          '';
          "sonarr.lab.adhia.net".extraConfig = ''
            reverse_proxy 127.0.0.1:8989
            ${tls}
          '';
          "radarr.lab.adhia.net".extraConfig = ''
            reverse_proxy 127.0.0.1:7878
            ${tls}
          '';
          "overseerr.lab.adhia.net".extraConfig = ''
            reverse_proxy 127.0.0.1:5055
            ${tls}
          '';
          "pihole.lab.adhia.net".extraConfig = ''
            reverse_proxy localhost:8080
            ${tls}
          '';
          "hass.lab.adhia.net".extraConfig = ''
            reverse_proxy 127.0.0.1:8123
            ${tls}
          '';
          "gatus.lab.adhia.net".extraConfig = ''
            reverse_proxy 127.0.0.1:8085
            ${tls}
          '';
          "rummy.lab.adhia.net".extraConfig = ''
            reverse_proxy localhost:3000
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
