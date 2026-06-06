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
      nixosMods.plex
      nixosMods.pihole
      nixosMods.mafiaBot
      nixosMods.monitoring
      nixosMods.tailscale
      nixosMods.uptimeKuma
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
