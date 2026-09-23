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
                  href = "https://pihole.lab.adhia.net";
                  description = "DNS sinkhole and DHCP";
                  icon = "pi-hole.png";
                };
              }
              {
                "Plex" = {
                  href = "https://plex.lab.adhia.net";
                  description = "Media library";
                  icon = "plex.png";
                };
              }
              {
                "Home Assistant" = {
                  href = "https://hass.lab.adhia.net";
                  description = "Home automation";
                  icon = "home-assistant.png";
                };
              }
              {
                "Gatus" = {
                  href = "https://gatus.lab.adhia.net";
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
