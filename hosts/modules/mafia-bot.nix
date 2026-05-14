{
  pkgs,
  mafia-bot,
  config,
  ...
}:
{
  age.secrets.discord-token.file = ../../secrets/mafia-bot-discord-token.age;

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
}
