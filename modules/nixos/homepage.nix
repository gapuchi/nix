{ ... }:
{
  flake.modules.nixos.homepage =
    { config, ... }:
    let
      rev = config.system.configurationRevision;
    in
    {
      services.homepage-dashboard = {
        enable = true;
        listenPort = 8082;
        allowedHosts = "home.lab.adhia.net,localhost:8082,127.0.0.1:8082";

        settings = {
          title = "calculus";
          favicon = "/calculus.jpeg";
          headerStyle = "clean";
          statusStyle = "dot";
          layout = [
            { Services.style = "row"; }
            { Bots.style = "row"; }
          ];
        };

        widgets = [
          {
            resources = {
              cpu = true;
              memory = true;
              disk = "/";
            };
          }
          {
            datetime.format = {
              dateStyle = "long";
              timeStyle = "short";
            };
          }
          {
            greeting = {
              text_size = "sm";
              text = "nix rev ${if rev == null then "dirty" else rev}";
            };
          }
        ];

        services = [
          {
            Services = [
              {
                "Pi-hole" = {
                  href = "https://pihole.lab.adhia.net";
                  siteMonitor = "http://127.0.0.1:8080/api/info/version";
                  description = "DNS sinkhole and DHCP";
                  icon = "pi-hole.png";
                };
              }
              {
                "Plex" = {
                  href = "https://plex.lab.adhia.net";
                  siteMonitor = "http://127.0.0.1:32400/web";
                  description = "Media library";
                  icon = "plex.png";
                };
              }
              {
                "Auto Upgrade" = {
                  siteMonitor = "http://127.0.0.1:8083/nixos-upgrade.timer";
                  description = "Polls calculus tag every 5 min";
                  icon = "mdi-update";
                };
              }
            ];
          }
          {
            Bots = [
              {
                "Mafia Bot" = {
                  siteMonitor = "http://127.0.0.1:8083/mafia-bot";
                  description = "Discord mafia game bot";
                  icon = "/rokt-leeg.jpg";
                };
              }
              {
                "League Bot" = {
                  siteMonitor = "http://127.0.0.1:8083/league-bot";
                  description = "Discord League of Legends bot";
                  icon = "mdi-trophy";
                };
              }
            ];
          }
        ];
      };
    };
}
