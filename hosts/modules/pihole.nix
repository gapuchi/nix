{ pkgs, pkgs-stable, ... }:
{

  networking = {
    interfaces.enp3s0.ipv4.addresses = [
      {
        address = "192.168.1.2";
        prefixLength = 24;
      }
    ];

    defaultGateway = "192.168.1.1";
    nameservers = [ "127.0.0.1" ];
  };

  # Allow DNS only on the LAN and Tailscale interfaces — not globally.
  # This is safer than openFirewallDNS = true (which opens port 53 on all interfaces)
  # because it keeps the boundary inside NixOS regardless of router config.
  networking.firewall.interfaces = {
    "enp3s0" = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [
        53
        67
        68
      ]; # DNS + DHCP
    };

    "tailscale0" = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    };
  };

  services.pihole-ftl = {
    enable = true;
    # Until https://github.com/NixOS/nixpkgs/pull/496654 is merged
    package = pkgs-stable.pihole-ftl;

    openFirewallDNS = false;
    openFirewallDHCP = false;
    useDnsmasqConfig = true;

    settings = {
      dns = {
        listeningMode = "ALL";
        hosts = [
          "192.168.1.1 router"
          "192.168.1.2 calculus"
          "192.168.1.3 snowy"
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
        router = "192.168.1.1";
        hosts = [
          "24:5E:BE:45:A2:F0,192.168.1.3,snowy"
        ];
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
    # Until https://github.com/NixOS/nixpkgs/pull/496654 is merged
    package = pkgs-stable.pihole-web;

    ports = [
      "8080"
      "8443s"
    ];
  };

  services.dnsmasq = {
    enable = false;
    settings = {
      address = "/.home.arpa/192.168.1.2";
    };
  };
}
