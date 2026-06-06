{ inputs, config, ... }:

let
  sshKeys = import ../_lib/ssh-keys.nix;
  nixosMods = config.flake.modules.nixos;
in
{
  flake.nixosConfigurations.haddock = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      ../../hosts/haddock/hardware-configuration.nix
      nixosMods.gapuchiLinuxDesktop
      nixosMods.tailscale
      {
        my.nixos = {
          hostName = "haddock";
          authorizedKeys = with sshKeys; [
            calculus
            tintin
          ];
        };

        networking.firewall.allowedTCPPorts = [ 22 8081 ];
      }
    ];
  };
}
