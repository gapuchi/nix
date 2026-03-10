{ pkgs, ... }:
{

  networking = {
    useDHCP = false;
    interfaces.enp3s0.ipv4.addresses = [
      {
        address = "192.168.1.2";
        prefixLength = 24;
      }
    ];

    defaultGateway = "192.168.1.1";
    nameservers = [ "127.0.0.1" ];

    firewall = {
      enable = true;
      allowedTCPPorts = [
        80
        443
        53
      ];

      allowedUDPPorts = [
        53
        67
        68
      ];
    };
  };

  services.pihole-ftl = {
    enable = true;
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

  };

  services.pihole-web = {
    enable = true;
    ports = [ "443s" ];
  };
}
