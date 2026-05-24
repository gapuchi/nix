{ ... }:
{
  flake.modules.nixos.uptimeKuma = {
    services.uptime-kuma.enable = true;
    systemd.services.uptime-kuma.serviceConfig.SupplementaryGroups = [ "docker" ];
  };
}
