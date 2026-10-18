{ lib, ... }:

let
  devices = import ../_lib/devices.nix;
  webUIPort = 8265;
  serverPort = 8266;
in
{
  flake.modules.nixos.tdarr = {
    users.groups.media = { };
    users.users.tdarr.extraGroups = [ "media" ];

    services.tdarr.server = {
      enable = true;
      inherit serverPort webUIPort;
    };

    systemd.services.tdarr-server = {
      unitConfig.RequiresMountsFor = [ devices.snowy.mountPoint ];
      serviceConfig = {
        Group = lib.mkForce "media";
        UMask = "0002";
        ReadWritePaths = [ devices.snowy.mountPoint ];
      };
    };

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ serverPort ];
  };

  flake.modules.nixos.tdarrNode = {
    users.groups.video = { };
    users.groups.render = { };
    users.users.tdarr.extraGroups = [
      "video"
      "render"
    ];

    services.tdarr.nodes.worker = {
      serverURL = "http://${devices.calculus.tailscaleIp}:${toString serverPort}";
      type = "unmapped";
    };

    systemd.services.tdarr-node-worker = {
      after = [
        "network-online.target"
        "tailscaled.service"
      ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Nice = 19;
        IOSchedulingClass = "idle";
      };
    };
  };
}
