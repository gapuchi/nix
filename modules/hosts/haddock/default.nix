{ inputs, config, ... }:

let
  devices = import ../../_lib/devices.nix;
  sshKeys = import ../../_lib/ssh-keys.nix;
  nixosMods = config.flake.modules.nixos;
in
{
  flake.nixosConfigurations.haddock = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      ../../../hosts/haddock/hardware-configuration.nix
      nixosMods.gapuchiLinuxDesktop
      nixosMods.tailscale
      nixosMods.tdarrNode
      {
        my.nixos = {
          hostName = "haddock";
          authorizedKeys = with sshKeys; [
            calculus
            tintin
          ];
        };

        boot.supportedFilesystems = [ "nfs" ];

        fileSystems.${devices.snowy.mountPoint} = {
          device = "${devices.snowy.ip}:/Public";
          fsType = "nfs";
          options = [
            "nfsvers=4.1"
            "nofail"
          ];
        };

        networking.firewall.allowedTCPPorts = [
          22
          8081
        ];
      }
    ];
  };
}
