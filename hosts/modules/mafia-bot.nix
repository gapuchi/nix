{
  pkgs,
  mafia-bot,
  config,
  ...
}:
let
  pushScript = pkgs.writeShellApplication {
    name = "mafia-bot-kuma-push";
    runtimeInputs = [ pkgs.curl pkgs.systemd ];
    text = ''
      url=$(< ${config.age.secrets.mafia-bot-kuma-push-url.path})
      if systemctl is-active --quiet mafia-bot.service; then
        curl -fsS "$url?status=up&msg=OK&ping="
      else
        curl -fsS "$url?status=down&msg=stopped&ping="
      fi
    '';
  };
in
{
  age.secrets = {
    discord-token.file = ../../secrets/discord-token.age;
    mafia-bot-kuma-push-url.file = ../../secrets/mafia-bot-kuma-push-url.age;
  };

  systemd.services.mafia-bot = {
    description = "Mafia Bot";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${mafia-bot.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/mafia-bot";
      EnvironmentFile = config.age.secrets.discord-token.path;
      DynamicUser = true;
      Restart = "always";
    };
  };

  systemd.services.mafia-bot-kuma-push = {
    description = "Mafia Bot Uptime Kuma heartbeat";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pushScript}/bin/mafia-bot-kuma-push";
    };
  };

  systemd.timers.mafia-bot-kuma-push = {
    description = "Mafia Bot Uptime Kuma heartbeat timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "30s";
      OnUnitActiveSec = "60s";
    };
  };
}
