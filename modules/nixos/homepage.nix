{ inputs, ... }:

let
  lab = inputs.nix-private.lab;
  href = name: "https://${name}.${lab.domain}";
in
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
        allowedHosts = "home.${lab.domain},localhost:8082,127.0.0.1:8082";

        settings = {
          title = "calculus";
          favicon = "/calculus.jpeg";
          headerStyle = "clean";
          layout = [
            { Services.style = "row"; }
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
                  href = href "pihole";
                  description = "DNS sinkhole and DHCP";
                  icon = "pi-hole.png";
                };
              }
              {
                "Plex" = {
                  href = href "plex";
                  description = "Media library";
                  icon = "plex.png";
                };
              }
              {
                "Jellyfin" = {
                  href = href "jellyfin";
                  description = "Media library";
                  icon = "jellyfin.png";
                };
              }
              {
                "qBittorrent" = {
                  href = href "qbittorrent";
                  description = "Download client";
                  icon = "qbittorrent.png";
                };
              }
              {
                "Prowlarr" = {
                  href = href "prowlarr";
                  description = "Indexer manager";
                  icon = "prowlarr.png";
                };
              }
              {
                "Sonarr" = {
                  href = href "sonarr";
                  description = "TV shows";
                  icon = "sonarr.png";
                };
              }
              {
                "Radarr" = {
                  href = href "radarr";
                  description = "Movies";
                  icon = "radarr.png";
                };
              }
              {
                "Overseerr" = {
                  href = href "overseerr";
                  description = "Media requests";
                  icon = "overseerr.png";
                };
              }
              {
                "Tdarr" = {
                  href = href "tdarr";
                  description = "Media transcoding";
                  icon = "tdarr.png";
                };
              }
              {
                "Home Assistant" = {
                  href = href "hass";
                  description = "Home automation";
                  icon = "home-assistant.png";
                };
              }
              {
                "Rummy" = {
                  href = href "rummy";
                  description = "Points Rummy score sheet";
                  icon = "mdi-cards-playing";
                };
              }
              {
                "Gatus" = {
                  href = href "gatus";
                  description = "Uptime alerts";
                  icon = "gatus.png";
                  widget = {
                    type = "gatus";
                    url = "http://127.0.0.1:8085";
                  };
                };
              }
            ];
          }
        ];
      };
    };
}
