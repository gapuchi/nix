{ inputs, ... }:

let
  devices = inputs.nix-private.devices;
  lab = inputs.nix-private.lab;
  site = name: "${name}.${lab.domain}";
in
{
  flake.modules.nixos.pihole =
    { ... }:
    {
      networking = {
        interfaces.enp3s0.ipv4.addresses = [
          {
            address = devices.calculus.ip;
            prefixLength = 24;
          }
        ];
        defaultGateway = devices.router.ip;
        nameservers = [ "127.0.0.1" ];
      };

      # Allow DNS only on the LAN and Tailscale interfaces.
      networking.firewall.interfaces = {
        "enp3s0" = {
          allowedTCPPorts = [ 53 ];
          allowedUDPPorts = [
            53
            67
            68
          ];
        };
        "tailscale0" = {
          allowedTCPPorts = [ 53 ];
          allowedUDPPorts = [ 53 ];
        };
      };

      services.pihole-ftl = {
        enable = true;
        openFirewallDNS = false;
        openFirewallDHCP = false;
        useDnsmasqConfig = true;
        settings = {
          dns = {
            listeningMode = "ALL";
            hosts = [
              "${devices.router.ip} router"
              "${devices.calculus.tailscaleIp} calculus ${lab.calculusHostname}"
              "${devices.snowy.ip} snowy"
            ];
            cnameRecords = [
              "${site "home"},${lab.calculusHostname}"
              "${site "pihole"},${lab.calculusHostname}"
              "${site "plex"},${lab.calculusHostname}"
              "${site "jellyfin"},${lab.calculusHostname}"
              "${site "qbittorrent"},${lab.calculusHostname}"
              "${site "prowlarr"},${lab.calculusHostname}"
              "${site "sonarr"},${lab.calculusHostname}"
              "${site "radarr"},${lab.calculusHostname}"
              "${site "overseerr"},${lab.calculusHostname}"
              "${site "tdarr"},${lab.calculusHostname}"
              "${site "hass"},${lab.calculusHostname}"
              "${site "gatus"},${lab.calculusHostname}"
              "${site "rummy"},${lab.calculusHostname}"
            ];
            rateLimit = {
              count = 0;
              interval = 0;
            };
            upstreams = [
              "8.8.8.8"
              "1.1.1.1"
            ];
          };
          dhcp = {
            active = true;
            start = lab.dhcp.start;
            end = lab.dhcp.end;
            router = devices.router.ip;
            hosts = [ "${devices.snowy.mac},${devices.snowy.ip},snowy" ];
          };
        };
        lists = [
          {
            url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
            enabled = true;
            description = "Steven Black's HOSTS";
          }
          {
            url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt";
            enabled = true;
            description = "hagezi blocklist";
          }
        ];
      };

      services.pihole-web = {
        enable = true;
        ports = [ "127.0.0.1:8080" ];
      };

      services.dnsmasq = {
        enable = false;
        settings.address = "/.home.arpa/${devices.calculus.ip}";
      };
    };
}
