{ ... }:
{
  flake.modules.nixos.golink =
    { pkgs, ... }:
    {
      systemd.services.golink = {
        description = "Tailscale golink";
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];

        environment.XDG_CONFIG_HOME = "/var/lib/golink";

        serviceConfig = {
          ExecStart = "${pkgs.golink}/bin/golink -sqlitedb /var/lib/golink/golink.db";
          EnvironmentFile = "-/var/lib/golink/auth.env";
          StateDirectory = "golink";
          DynamicUser = true;
          Restart = "on-failure";
        };
      };
    };
}
