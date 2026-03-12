{ pkgs, ... }:
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

  services.pihole-ftl = {
    enable = true;

    openFirewallDNS = true;
    openFirewallDHCP = true;
    openFirewallWebserver = true;

    settings = {
      dns.upstreams = [
        "8.8.8.8"
        "1.1.1.1"
      ];

      dhcp = {
        active = false;
        start = "192.168.1.10";
        end = "192.168.1.255";
        router = "192.168.1.1";
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
      "443s"
      "80"
    ];
  };
}
