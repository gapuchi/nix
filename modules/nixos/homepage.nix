{ ... }:
{
  flake.modules.nixos.homepage =
    { ... }:
    {
      services.homepage-dashboard = {
        enable = true;
        listenPort = 8082;
        allowedHosts = "home.lab.adhia.net,localhost:8082,127.0.0.1:8082";

        settings = {
          title = "calculus";
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
                "Netdata" = {
                  href = "https://netdata.lab.adhia.net";
                  siteMonitor = "http://127.0.0.1:19999/";
                  description = "System metrics";
                  icon = "netdata.png";
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
            ];
          }
          {
            Bots = [
              {
                "Mafia Bot" = {
                  siteMonitor = "http://127.0.0.1:8083/mafia-bot";
                  description = "Discord mafia game bot";
                  icon = "mdi-domino-mask";
                };
              }
              {
                "League Bot" = {
                  siteMonitor = "http://127.0.0.1:8083/league-bot";
                  description = "Discord League of Legends bot";
                  icon = "league-of-legends.png";
                };
              }
            ];
          }
        ];
      };
    };
}
