{ ... }:

let
  devices = import ../_lib/devices.nix;
  library = "${devices.snowy.mountPoint}/media/Books";
in
{
  flake.modules.nixos.calibreWeb = {
    users.groups.media = { };
    users.users.calibre-web.extraGroups = [ "media" ];

    services.calibre-web = {
      enable = true;
      listen = {
        ip = "127.0.0.1";
        port = 8086;
      };
      options = {
        calibreLibrary = library;
        enableBookUploading = true;
        enableBookConversion = true;
        enableKepubify = true;
      };
    };

    systemd.services.calibre-web = {
      unitConfig.RequiresMountsFor = [ devices.snowy.mountPoint ];
      serviceConfig.UMask = "0002";
    };
  };
}
