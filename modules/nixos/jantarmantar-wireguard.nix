{ ... }:

let
  devices = import ../_lib/devices.nix;
  tvIp = devices.tv.ip;
  table = "51820";
in
{
  flake.modules.nixos.jantarmantarWireguard =
    { config, ... }:
    {
      age.secrets.jantarmantar-wg.file = ../../secrets/jantarmantar-wg.age;

      networking.nat = {
        enable = true;
        externalInterface = "jantarmantar";
        internalIPs = [ "${tvIp}/32" ];
      };

      networking.wireguard.interfaces.jantarmantar = {
        ips = [ "10.0.0.6/24" ];
        privateKeyFile = config.age.secrets.jantarmantar-wg.path;
        # AllowedIPs stay in this table so calculus keeps its LAN default route.
        table = table;
        peers = [
          {
            publicKey = "TXTu4pt0q35E5T6Z4imIzc5yGh2r5U7AQUIPOEEaXnE=";
            endpoint = "75.181.239.50:51820";
            allowedIPs = [ "0.0.0.0/0" ];
            persistentKeepalive = 25;
          }
        ];
        postSetup = ''
          ip rule del from ${tvIp}/32 lookup ${table} priority 100 2>/dev/null || true
          ip rule add from ${tvIp}/32 lookup ${table} priority 100
        '';
        postShutdown = ''
          ip rule del from ${tvIp}/32 lookup ${table} priority 100 2>/dev/null || true
        '';
      };

      systemd.services.wireguard-jantarmantar = {
        after = [ "agenix-install-secrets.service" ];
        requires = [ "agenix-install-secrets.service" ];
      };

      services.pihole-ftl.settings.misc.dnsmasq_lines = [
        "dhcp-option=tag:tv,option:router,${devices.calculus.ip}"
        "dhcp-option=tag:tv,option:dns-server,10.0.0.1"
      ];
    };
}
