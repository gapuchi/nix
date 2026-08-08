{ inputs, ... }:
{
  flake.modules.nixos.leagueBot =
    { pkgs, config, ... }:
    let
      league-bot = inputs.league-bot.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      age.secrets.league-bot-env.file = ../../secrets/league-bot.env.age;

      systemd.services.league-bot = {
        description = "League Bot";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "${league-bot}/bin/league-bot";
          EnvironmentFile = config.age.secrets.league-bot-env.path;
          StateDirectory = "league-bot";
          DynamicUser = true;
          Restart = "always";
        };
      };
    };
}
