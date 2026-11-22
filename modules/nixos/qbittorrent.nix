{ inputs, ... }:

let
  devices = inputs.nix-private.devices;
in
{
  flake.modules.nixos.qbittorrent =
    { config, lib, pkgs, ... }:
    let
      webuiPort = 8090;
      vpn = "proton";
      downloadDir = "${devices.snowy.mountPoint}/downloads";
      incompleteDir = "/var/lib/qBittorrent/.incomplete";
      webui = "http://192.168.15.1:${toString webuiPort}";
    in
    {
      imports = [ inputs.vpn-confinement.nixosModules.default ];

      age.secrets.proton-wg.file = "${inputs.nix-private}/secrets/proton-wg.age";

      vpnNamespaces.${vpn} = {
        enable = true;
        wireguardConfigFile = config.age.secrets.proton-wg.path;
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
        inherit webuiPort;

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
          Group = lib.mkForce "media";
          PrivateUsers = lib.mkForce false;
          UMask = "0002";
        };
        vpnConfinement = {
          enable = true;
          vpnNamespace = vpn;
        };
      };

      # Proton's 60s NAT-PMP loop, run in the namespace. The two steps after it
      # are the parts their terminal snippet leaves to you: listen on the port
      # they assigned, and accept it on the tunnel interface.
      systemd.services.qbittorrent-proton-forward = {
        description = "Renew the Proton NAT-PMP lease for qBittorrent";
        wantedBy = [ "multi-user.target" ];
        wants = [
          "proton.service"
          "qbittorrent.service"
        ];
        after = [
          "proton.service"
          "qbittorrent.service"
        ];
        path = with pkgs; [
          coreutils
          curl
          gnugrep
          iproute2
          iptables
          libnatpmp
        ];
        script = ''
          set -euo pipefail
          while true; do
            date
            udp=$(ip netns exec proton natpmpc -a 1 0 udp 60 -g 10.2.0.1)
            tcp=$(ip netns exec proton natpmpc -a 1 0 tcp 60 -g 10.2.0.1)
            printf '%s\n%s\n' "$udp" "$tcp"

            port=$(printf '%s\n' "$udp" | grep -oE 'Mapped public port [0-9]+' | grep -oE '[0-9]+')
            test "$port" = "$(printf '%s\n' "$tcp" | grep -oE 'Mapped public port [0-9]+' | grep -oE '[0-9]+')"

            ip netns exec proton iptables -N proton-fwd 2>/dev/null || true
            ip netns exec proton iptables -C INPUT -j proton-fwd 2>/dev/null \
              || ip netns exec proton iptables -A INPUT -j proton-fwd
            if ! ip netns exec proton iptables -C proton-fwd -i proton0 -p tcp --dport "$port" -j ACCEPT 2>/dev/null; then
              ip netns exec proton iptables -F proton-fwd
              ip netns exec proton iptables -A proton-fwd -i proton0 -p tcp --dport "$port" -j ACCEPT
              ip netns exec proton iptables -A proton-fwd -i proton0 -p udp --dport "$port" -j ACCEPT
            fi

            current=$(curl -fsS --max-time 5 ${webui}/api/v2/app/preferences | grep -oE '"listen_port": *[0-9]+' | grep -oE '[0-9]+')
            if [ "$current" != "$port" ]; then
              curl -fsS --max-time 5 -X POST ${webui}/api/v2/app/setPreferences \
                --data-urlencode "json={\"listen_port\":$port}"
            fi
            sleep 45
          done
        '';
        serviceConfig = {
          Type = "simple";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };

      systemd.tmpfiles.settings.qbittorrent-incomplete."${incompleteDir}"."d" = {
        mode = "0755";
        user = "qbittorrent";
        group = "qbittorrent";
      };
    };
}
