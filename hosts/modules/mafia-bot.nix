{
  pkgs,
  mafia-bot,
  config,
  ...
}:
{
  age.secrets.discord-token.file = ../../secrets/discord-token.age;

  systemd.services.mafia-bot = {
    description = "Mafia Bot";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${mafia-bot.packages.${pkgs.system}.default}/bin/mafia-bot";
      EnvironmentFile = config.age.secrets.discord-token.path;
      DynamicUser = true;
      Restart = "always";
    };
  };
}
