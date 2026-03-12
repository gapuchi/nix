{ pkgs, ... }:
{

  services.pihole-ftl = {
    enable = true;

    openFirewallDNS = true;
    openFirewallWebserver = true;

    settings = {
      dns = {
        hosts = [
          "192.168.1.1 router"
          "192.168.1.2 calculus"
          "192.168.1.3 snowy"
        ];

        upstreams = [
          "8.8.8.8"
          "1.1.1.1"
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
    ports = [
      "443s"
      "80"
    ];
  };
}
