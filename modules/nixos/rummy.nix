{ inputs, ... }:
{
  flake.modules.nixos.rummy =
    { pkgs, lib, ... }:
    let
      points-rummy = inputs.rummy.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      systemd.services.points-rummy = {
        description = "Points Rummy score sheet";
        wantedBy = [ "multi-user.target" ];
        environment = {
          HOSTNAME = "127.0.0.1";
          PORT = "3000";
          RUMMY_DB_PATH = "/var/lib/points-rummy/rummy.sqlite";
          NODE_ENV = "production";
          NEXT_TELEMETRY_DISABLED = "1";
        };
        serviceConfig = {
          ExecStart = lib.getExe points-rummy;
          WorkingDirectory = "/var/lib/points-rummy";
          StateDirectory = "points-rummy";
          DynamicUser = true;
          Restart = "on-failure";
        };
      };
    };
}
