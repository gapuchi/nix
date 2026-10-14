{ inputs, ... }:

let
  devices = import ../_lib/devices.nix;
in
{
  flake.modules.nixos.qbittorrent =
    { config, lib, ... }:
    let
      webuiPort = 8090;
      torrentingPort = 50413;
      vpn = "mullvad";
      downloadDir = "${devices.snowy.mountPoint}/downloads";
      incompleteDir = "/var/lib/qBittorrent/.incomplete";
    in
    {
      imports = [ inputs.vpn-confinement.nixosModules.default ];

      age.secrets.mullvad-wg.file = ../../secrets/mullvad-wg.age;

      vpnNamespaces.${vpn} = {
        enable = true;
        wireguardConfigFile = config.age.secrets.mullvad-wg.path;
        accessibleFrom = [
          "192.168.0.0/16"
          "100.64.0.0/10"
        ];
        allowedEgress = [ devices.snowy.ip ];
        portMappings = [
          {
            from = webuiPort;
            to = webuiPort;
          }
        ];
      };

      services.qbittorrent = {
        enable = true;
        inherit webuiPort torrentingPort;

        serverConfig = {
          LegalNotice.Accepted = true;

          BitTorrent.Session = {
            DefaultSavePath = downloadDir;
            TempPath = incompleteDir;
            TempPathEnabled = true;

            QueueingSystemEnabled = true;
            MaxActiveDownloads = 10;
            MaxActiveTorrents = 50;
            IgnoreSlowTorrentsForQueueing = true;

            GlobalMaxRatio = 1;
            GlobalMaxSeedingMinutes = 1440;
          };

          Network.PortForwardingEnabled = false;

          Preferences.WebUI = {
            Address = "*";
            AuthSubnetWhitelistEnabled = true;
            AuthSubnetWhitelist = "192.168.15.0/24,100.64.0.0/10";
            HostHeaderValidation = false;
            CSRFProtection = false;
            ReverseProxySupportEnabled = true;
            TrustedReverseProxiesList = "192.168.15.5";
          };
        };
      };

      users.groups.media = { };
      users.users.qbittorrent.extraGroups = [ "media" ];

      systemd.services.qbittorrent = {
        unitConfig.RequiresMountsFor = [ devices.snowy.mountPoint ];
        serviceConfig = {
          PrivateUsers = lib.mkForce false;
          UMask = "0002";
        };
        vpnConfinement = {
          enable = true;
          vpnNamespace = vpn;
        };
      };

      systemd.tmpfiles.settings.qbittorrent-incomplete."${incompleteDir}"."d" = {
        mode = "0755";
        user = "qbittorrent";
        group = "qbittorrent";
      };
    };
}
