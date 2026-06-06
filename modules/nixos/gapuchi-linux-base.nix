{ inputs, config, ... }:
let
  nixosMods = config.flake.modules.nixos;
in
{
  flake.modules.nixos.gapuchiLinuxBase = {
    imports = with nixosMods; [ base ] ++ [
      inputs.home-manager.nixosModules.home-manager
    ];

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    networking.networkmanager.enable = true;
  };
}
