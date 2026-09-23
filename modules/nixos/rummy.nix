{ inputs, ... }:
{
  flake.modules.nixos.rummy =
    { pkgs, config, ... }:
    let
      points-rummy = inputs.rummy.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      age.secrets.rummy-env.file = ../../secrets/rummy.env.age;
      age.secrets.rummy-google-sa.file = ../../secrets/rummy-google-sa.age;

      systemd.services.points-rummy = {
        description = "Points Rummy score sheet";
        wantedBy = [ "multi-user.target" ];
        environment = {
          HOSTNAME = "127.0.0.1";
          PORT = "3000";
          RUMMY_DB_PATH = "/var/lib/points-rummy/rummy.sqlite";
          GOOGLE_APPLICATION_CREDENTIALS = "%d/google-sa";
        };
        serviceConfig = {
          ExecStart = "${points-rummy}/bin/points-rummy";
          EnvironmentFile = config.age.secrets.rummy-env.path;
          LoadCredential = "google-sa:${config.age.secrets.rummy-google-sa.path}";
          StateDirectory = "points-rummy";
          WorkingDirectory = "/var/lib/points-rummy";
          DynamicUser = true;
          Restart = "always";
        };
      };
    };
}
