{ inputs, ... }:

let
  lab = inputs.nix-private.lab;
  site = name: "${name}.${lab.domain}";
in
{
  flake.modules.nixos.caddy =
    { pkgs, config, ... }:
    let
      # Wildcard cert for *.${lab.domain} via Let's Encrypt DNS-01 (Cloudflare).
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
          hash = "sha256-tubXIDCJnO2mvdnPlZclwDhNGaeeYLSt7lnni3+pXDo=";
        };
        virtualHosts = {
          "${site "home"}".extraConfig = ''
            handle /calculus.jpeg {
              root * ${./assets}
              file_server
            }
            reverse_proxy localhost:8082
            ${tls}
          '';
          "${site "plex"}".extraConfig = ''
            reverse_proxy localhost:32400
            ${tls}
          '';
          "${site "jellyfin"}".extraConfig = ''
            reverse_proxy 127.0.0.1:8096
            ${tls}
          '';
          "${site "qbittorrent"}".extraConfig = ''
            reverse_proxy 192.168.15.1:8090
            ${tls}
          '';
          "${site "prowlarr"}".extraConfig = ''
            reverse_proxy 127.0.0.1:9696
            ${tls}
          '';
          "${site "sonarr"}".extraConfig = ''
            reverse_proxy 127.0.0.1:8989
            ${tls}
          '';
          "${site "radarr"}".extraConfig = ''
            reverse_proxy 127.0.0.1:7878
            ${tls}
          '';
          "${site "overseerr"}".extraConfig = ''
            reverse_proxy 127.0.0.1:5055
            ${tls}
          '';
          "${site "tdarr"}".extraConfig = ''
            reverse_proxy 127.0.0.1:8265
            ${tls}
          '';
          "${site "pihole"}".extraConfig = ''
            reverse_proxy localhost:8080
            ${tls}
          '';
          "${site "hass"}".extraConfig = ''
            reverse_proxy 127.0.0.1:8123
            ${tls}
          '';
          "${site "gatus"}".extraConfig = ''
            reverse_proxy 127.0.0.1:8085
            ${tls}
          '';
          "${site "rummy"}".extraConfig = ''
            reverse_proxy localhost:3000
            ${tls}
          '';
        };
      };

      # Cloudflare API token (Zone:DNS:Edit) as `CF_API_TOKEN=...`.
      age.secrets.caddy-dns-token.file = "${inputs.nix-private}/secrets/caddy-dns-token.age";
      systemd.services.caddy.serviceConfig.EnvironmentFile = config.age.secrets.caddy-dns-token.path;

      # 80/443 are only reachable over Tailscale.
      networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
        80
        443
      ];
    };
}
