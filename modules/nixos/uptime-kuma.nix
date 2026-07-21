{ ... }:
{
  flake.modules.nixos.uptimeKuma = {
    services.uptime-kuma.enable = true;
  };
}
