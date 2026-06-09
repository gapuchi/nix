{ inputs, ... }:
{
  flake.modules.nixos.worldCupBot =
    { pkgs, config, ... }:
    let
      world-cup-bot = inputs.world-cup-bot.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      age.secrets.world-cup-bot-env.file = ../../secrets/world-cup-bot.env.age;

      systemd.services.world-cup-bot = {
        description = "World Cup Bot";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "${world-cup-bot}/bin/world-cup-bot";
          EnvironmentFile = config.age.secrets.world-cup-bot-env.path;
          StateDirectory = "world-cup-bot";
          DynamicUser = true;
          Restart = "always";
        };
      };
    };
}
