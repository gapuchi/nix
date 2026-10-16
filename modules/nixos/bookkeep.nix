{ ... }:

let
  devices = import ../_lib/devices.nix;
  port = 8087;
in
{
  flake.modules.nixos.bookkeep =
    { config, pkgs, ... }:
    {
      age.secrets.bookkeep-env.file = ../../secrets/bookkeep.env.age;

      virtualisation.oci-containers.containers.bookkeep = {
        image = "docker.io/akiraslingshot/bookkeep:v1.5.0";
        ports = [ "127.0.0.1:${toString port}:8000" ];
        networks = [ "slirp4netns:allow_host_loopback=true" ];
        environmentFiles = [ config.age.secrets.bookkeep-env.path ];
        volumes = [
          "/var/lib/bookkeep:/app/data"
          "${devices.snowy.mountPoint}/downloads:/downloads"
        ];
      };

      systemd.services.podman-bookkeep = {
        path = [ pkgs.slirp4netns ];
        unitConfig.RequiresMountsFor = [ devices.snowy.mountPoint ];
      };
    };
}
