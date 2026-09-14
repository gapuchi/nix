{ inputs, ... }:
{
  flake.modules.nixos.leagueBot =
    { pkgs, config, ... }:
    let
      league-bot = inputs.league-bot.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      age.secrets.league-bot-env.file = ../../secrets/league-bot.env.age;

      users.users.league-bot = {
        isSystemUser = true;
        group = "league-bot";
      };
      users.groups.league-bot = { };

      systemd.tmpfiles.rules = [
        "d /var/lib/league-bot 0770 league-bot league-bot -"
        "Z /var/lib/league-bot - league-bot league-bot -"
      ];

      systemd.services.league-bot = {
        description = "League Bot";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "${league-bot}/bin/league-bot";
          EnvironmentFile = config.age.secrets.league-bot-env.path;
          Environment = "DATABASE_PATH=/var/lib/league-bot/league_bot.db";
          User = "league-bot";
          Group = "league-bot";
          WorkingDirectory = "/var/lib/league-bot";
          StateDirectory = "league-bot";
          StateDirectoryMode = "0770";
          UMask = "0007";
          Restart = "always";
        };
      };
    };
}
