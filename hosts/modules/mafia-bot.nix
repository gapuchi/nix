{ pkgs, mafia-bot, ... }:
{
  systemd.services.mafia-bot = {
    description = "Mafia Bot";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${mafia-bot.packages.${pkgs.system}.default}/bin/mafia-bot";
      Restart = "always";
    };
  };
}
