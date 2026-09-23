{ inputs, ... }:
{
  flake.modules.nixos.rummy =
    { pkgs, ... }:
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
        };
        serviceConfig = {
          ExecStart = "${points-rummy}/bin/points-rummy";
          StateDirectory = "points-rummy";
          WorkingDirectory = "/var/lib/points-rummy";
          DynamicUser = true;
          Restart = "always";
        };
      };
    };
}
