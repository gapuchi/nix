{ ... }:
{
  flake.modules.nixos.tailscale = {
    services.tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "server";
      extraSetFlags = [ "--advertise-exit-node" ];
    };
  };
}
