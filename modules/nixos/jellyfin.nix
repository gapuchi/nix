{ ... }:
{
  flake.modules.nixos.jellyfin = {
    services.jellyfin.enable = true;
    users.users.jellyfin.extraGroups = [ "media" ];
  };
}
