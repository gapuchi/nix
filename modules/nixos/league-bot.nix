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

      systemd.services.league-bot = {
        description = "League Bot";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "${league-bot}/bin/league-bot";
          EnvironmentFile = config.age.secrets.league-bot-env.path;
          User = "league-bot";
          Group = "league-bot";
          StateDirectory = "league-bot";
          StateDirectoryMode = "0770";
          UMask = "0007";
          Restart = "always";
        };
      };
    };
}
