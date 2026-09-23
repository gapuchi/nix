{ ... }:
{
  flake.modules.nixos.gatus =
    { config, ... }:
    let
      check =
        group: name: url: {
          inherit group name url;
          interval = "60s";
          conditions = [ "[STATUS] <= 403" ];
          alerts = [ { type = "discord"; } ];
        };
    in
    {
      age.secrets.gatus-discord-webhook.file = ../../secrets/gatus-discord-webhook.age;

      services.gatus = {
        enable = true;
        environmentFile = config.age.secrets.gatus-discord-webhook.path;
        settings = {
          web = {
            address = "127.0.0.1";
            port = 8085;
          };
          storage = {
            type = "sqlite";
            path = "/var/lib/gatus/gatus.db";
          };
          alerting.discord = {
            "webhook-url" = "\${GATUS_DISCORD_WEBHOOK_URL}";
            "default-alert" = {
              enabled = true;
              description = "health check failed";
              "send-on-resolved" = true;
              "failure-threshold" = 3;
              "success-threshold" = 2;
            };
          };
          endpoints = [
            (check "Services" "Pi-hole" "http://127.0.0.1:8080/api/info/version")
            (check "Services" "Plex" "http://127.0.0.1:32400/web")
            (check "Services" "Home Assistant" "http://127.0.0.1:8123")
            (check "Services" "Rummy" "http://127.0.0.1:3000")
            (check "Services" "Auto Upgrade" "http://127.0.0.1:8083/nixos-upgrade.timer")
            (check "Bots" "Mafia Bot" "http://127.0.0.1:8083/mafia-bot")
            (check "Bots" "League Bot" "http://127.0.0.1:8084/health")
          ];
        };
      };
    };
}
