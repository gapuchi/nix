{ inputs, ... }:
{
  flake.modules.nixos.rummy =
    { pkgs, lib, ... }:
    let
      points-rummy = inputs.rummy.packages.${pkgs.stdenv.hostPlatform.system}.default;
      dataDir = "/var/lib/points-rummy";
    in
    {
      systemd.services.points-rummy = {
        description = "Points Rummy score sheet";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        environment = {
          HOSTNAME = "127.0.0.1";
          PORT = "3000";
          RUMMY_DB_PATH = "${dataDir}/rummy.sqlite";
          NODE_ENV = "production";
          NEXT_TELEMETRY_DISABLED = "1";
        };
        serviceConfig = {
          ExecStart = lib.getExe points-rummy;
          WorkingDirectory = dataDir;
          StateDirectory = "points-rummy";
          DynamicUser = true;
          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectSystem = "strict";
          ProtectHome = true;
          Restart = "on-failure";
          RestartSec = 2;
        };
      };
    };
}
