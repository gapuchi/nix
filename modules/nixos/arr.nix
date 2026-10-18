{ lib, ... }:

let
  devices = import ../_lib/devices.nix;
in
{
  flake.modules.nixos.arr =
    { utils, ... }:
    let
      snowyMount = "${utils.escapeSystemdPath devices.snowy.mountPoint}.mount";
      bind = "127.0.0.1";
      server = host: port: {
        inherit port;
        bindaddress = bind;
        allowedhosts = "${host}.lab.adhia.net,localhost,127.0.0.1";
      };
      auth = {
        required = "DisabledForLocalAddresses";
        trustcgnatipaddresses = true;
      };
      media = {
        after = [ snowyMount ];
        requires = [ snowyMount ];
        serviceConfig = {
          Group = lib.mkForce "media";
          PrivateUsers = lib.mkForce false;
          UMask = lib.mkForce "0002";
        };
      };
    in
    {
      users.groups.media = { };
      users.users = {
        sonarr.extraGroups = [ "media" ];
        radarr.extraGroups = [ "media" ];
      };

      services = {
        flaresolverr = {
          enable = true;
          port = 8191;
        };

        seerr = {
          enable = true;
          port = 5055;
          stateRevision = 1;
        };

        prowlarr = {
          enable = true;
          settings = {
            inherit auth;
            server = server "prowlarr" 9696;
          };
        };

        sonarr = {
          enable = true;
          settings = {
            inherit auth;
            server = server "sonarr" 8989;
          };
        };

        radarr = {
          enable = true;
          settings = {
            inherit auth;
            server = server "radarr" 7878;
          };
        };
      };

      systemd.services = {
        sonarr = media;
        radarr = media;
      };
    };
}
