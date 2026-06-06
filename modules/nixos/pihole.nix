{ ... }:

let
  devices = import ../_lib/devices.nix;
  calculusHostname = "calculus.home.arpa";
in
{
  flake.modules.nixos.pihole =
    { pkgs, ... }:
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
              "${devices.calculus.tailscaleIp} calculus ${calculusHostname}"
              "${devices.snowy.ip} snowy"
            ];
            cnameRecords = [
              "pihole.home.arpa,${calculusHostname}"
              "plex.home.arpa,${calculusHostname}"
              "uptime-kuma.home.arpa,${calculusHostname}"
              "netdata.home.arpa,${calculusHostname}"
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
            start = "192.168.1.100";
            end = "192.168.1.254";
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
        ports = [
          "8080"
          "8443s"
        ];
      };

      services.dnsmasq = {
        enable = false;
        settings.address = "/.home.arpa/${devices.calculus.ip}";
      };
    };
}
