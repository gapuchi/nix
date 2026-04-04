{ config, lib, ... }:

let
  cfg = config.services.openclaw-gateway;
in
{
  age.secrets.openclaw-gateway-env = {
    file = ../../secrets/openclaw-gateway-env.age;
    owner = "openclaw";
    group = "openclaw";
    mode = "0600";
  };

  services.openclaw-gateway = {
    enable = true;
    port = 3002;

    config = {
      gateway = {
        mode = "local";
        bind = "loopback";
        auth.mode = "token";
        controlUi = {
          enabled = true;
          allowedOrigins = [
            "https://openclaw.home.arpa"
            "127.0.0.1"
            "::1"
          ];
        };
      };
      agents.defaults = {
        model = "anthropic/claude-sonnet-4-6";
        workspace = "${cfg.stateDir}/workspace";
      };
      channels.discord = {
        enabled = true;
        groupPolicy = "allowlist";
        token = {
          source = "env";
          provider = "default";
          id = "DISCORD_BOT_TOKEN";
        };
        guilds."1489515613893431316".requireMention = true;
      };
    };

    environment = {
      NODE_ENV = "production";
      OPENCLAW_LOG_LEVEL = "debug";
    };

    environmentFiles = [
      config.age.secrets.openclaw-gateway-env.path
    ];
  };

  # Hardening — the upstream NixOS module sets none of these.
  systemd.services.openclaw-gateway.serviceConfig = {
    ProtectSystem = lib.mkForce "strict";
    ProtectHome = true;
    PrivateTmp = true;
    PrivateDevices = true;
    NoNewPrivileges = true;
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectKernelLogs = true;
    ProtectControlGroups = true;
    ProtectClock = true;
    ProtectHostname = true;
    ProtectProc = "invisible";
    RestrictAddressFamilies = [
      "AF_INET"
      "AF_INET6"
      "AF_UNIX"
      "AF_NETLINK"
    ];
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    LockPersonality = true;
    SystemCallArchitectures = "native";
    SystemCallFilter = [
      "@system-service"
      "~@privileged"
      "~@resources"
    ];
    CapabilityBoundingSet = "";
    AmbientCapabilities = "";
    UMask = "0077";
    ReadWritePaths = [ cfg.stateDir ];
  };
}
