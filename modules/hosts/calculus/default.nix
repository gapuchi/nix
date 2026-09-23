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
      nixosMods.pihole
      nixosMods.homeAssistant
      nixosMods.golink
      nixosMods.mafiaBot
      nixosMods.leagueBot
      nixosMods.rummy
      nixosMods.cachix
      nixosMods.serviceHealth
      # nixosMods.calculusDeploy
      nixosMods.tailscale
      (
        { config, ... }:
        {
          users.users.${config.my.nixos.username}.extraGroups = [ "league-bot" ];
        }
      )
      {
        my.nixos = {
          hostName = "calculus";
          authorizedKeys = with sshKeys; [
            tintin
            haddock
          ];
        };

        fileSystems."/mnt/snowy" = {
          device = "${devices.snowy.ip}:/Public";
          fsType = "nfs";
          options = [ "nfsvers=4.1" ];
        };

        system = {
          configurationRevision = inputs.self.rev or inputs.self.dirtyRev;
          nixos.label = inputs.self.rev or inputs.self.dirtyRev;
        };
      }
    ];
  };
}
