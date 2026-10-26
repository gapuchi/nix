{ inputs, lib, ... }:

let
  devices = import ../_lib/devices.nix;
  webUIPort = 8265;
  serverPort = 8266;
  tdarrPackage =
    pkgs:
    (import inputs.nixpkgs-tdarr {
      system = pkgs.stdenv.hostPlatform.system;
      config.allowUnfree = pkgs.config.allowUnfree;
    }).tdarr;
in
{
  flake.modules.nixos.tdarr = { pkgs, ... }: {
    users.groups.media = { };
    users.users.tdarr.extraGroups = [ "media" ];

    services.tdarr = {
      package = tdarrPackage pkgs;
      server = {
        enable = true;
        inherit serverPort webUIPort;
      };
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

  flake.modules.nixos.tdarrNode = { pkgs, ... }: {
    users.groups.media = { };
    users.groups.video = { };
    users.groups.render = { };
    users.users.tdarr.extraGroups = [
      "media"
      "video"
      "render"
    ];

    services.tdarr.package = tdarrPackage pkgs;

    services.tdarr.nodes.worker = {
      serverURL = "http://${devices.calculus.tailscaleIp}:${toString serverPort}";
      type = "mapped";
      workers = {
        transcodeGPU = 1;
        transcodeCPU = 0;
        healthcheckGPU = 0;
        healthcheckCPU = 1;
      };
    };

    systemd.services.tdarr-node-worker = {
      after = [
        "network-online.target"
        "tailscaled.service"
      ];
      wants = [ "network-online.target" ];
      unitConfig.RequiresMountsFor = [ devices.snowy.mountPoint ];
      serviceConfig = {
        Group = lib.mkForce "media";
        UMask = "0002";
        Nice = 19;
        IOSchedulingClass = "idle";
        ReadWritePaths = [ devices.snowy.mountPoint ];
      };
    };
  };
}
