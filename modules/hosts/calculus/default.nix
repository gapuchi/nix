{ inputs, config, ... }:

let
  devices = import ../../_lib/devices.nix;
  sshKeys = import ../../_lib/ssh-keys.nix;
  nixosMods = config.flake.modules.nixos;
in
{
  flake.nixosConfigurations.calculus = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      ../../../hosts/calculus/hardware-configuration.nix
      inputs.agenix.nixosModules.default
      nixosMods.gapuchiServer
      nixosMods.caddy
      nixosMods.homepage
      nixosMods.gatus
      nixosMods.plex
      nixosMods.jellyfin
      nixosMods.qbittorrent
      nixosMods.arr
      nixosMods.tdarr
      nixosMods.pihole
      nixosMods.homeAssistant
      nixosMods.golink
      nixosMods.mafiaBot
      nixosMods.leagueBot
      nixosMods.rummy
      nixosMods.cachix
      nixosMods.serviceHealth
      nixosMods.tailscale
      (
        { config, ... }:
        {
          users.users.${config.my.nixos.username}.extraGroups = [
            "league-bot"
            "media"
          ];
        }
      )
      (
        { pkgs, ... }:
        {
          hardware.graphics = {
            enable = true;
            extraPackages = with pkgs; [
              intel-media-driver
              intel-compute-runtime
            ];
          };

          services.plex.accelerationDevices = [ "/dev/dri/renderD128" ];
          users.users.plex.extraGroups = [
            "video"
            "render"
          ];
          users.users.jellyfin.extraGroups = [
            "video"
            "render"
          ];

          my.nixos = {
            hostName = "calculus";
            authorizedKeys = with sshKeys; [
              tintin
              haddock
            ];
          };

          fileSystems.${devices.snowy.mountPoint} = {
            device = "${devices.snowy.ip}:/Public";
            fsType = "nfs";
            options = [ "nfsvers=4.1" ];
          };

          system = {
            configurationRevision = inputs.self.rev or inputs.self.dirtyRev;
            nixos.label = inputs.self.rev or inputs.self.dirtyRev;
          };
        }
      )
    ];
  };
}
