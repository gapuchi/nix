{ inputs, config, ... }:

let
  devices = import ../_lib/devices.nix;
  hmMods = config.flake.modules.homeManager;
  nixosMods = config.flake.modules.nixos;
in
{
  flake.nixosConfigurations.calculus = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      ../../hosts/calculus/hardware-configuration.nix
      inputs.agenix.nixosModules.default
      inputs.home-manager.nixosModules.home-manager
      nixosMods.caddy
      nixosMods.plex
      nixosMods.pihole
      nixosMods.mafiaBot
      nixosMods.monitoring
      nixosMods.tailscale
      nixosMods.uptimeKuma
      ({ pkgs, ... }: {
        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
        ];

        boot = {
          supportedFilesystems = [ "nfs" ];
          loader.systemd-boot.enable = true;
          loader.efi.canTouchEfiVariables = true;
        };

        fileSystems."/mnt/snowy" = {
          device = "${devices.snowy.ip}:/Public";
          fsType = "nfs";
          options = [ "nfsvers=4.1" ];
        };

        networking.hostName = "calculus";
        networking.networkmanager.enable = true;

        users.users.gapuchi = {
          isNormalUser = true;
          description = "Arjun Adhia";
          extraGroups = [
            "networkmanager"
            "wheel"
          ];
          shell = pkgs.zsh;
        };

        programs = {
          nix-ld.enable = true;
          zsh.enable = true;
        };

        nixpkgs.config.allowUnfree = true;

        environment.systemPackages = with pkgs; [
          git
          vim
          wget
          ghostty.terminfo
        ];

        services.openssh = {
          enable = true;
          settings.PasswordAuthentication = false;
          settings.KbdInteractiveAuthentication = false;
        };

        system.stateVersion = "25.11";

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.gapuchi = {
            imports = with hmMods; [ gapuchiServer ];
            my.home.homeDirectory = "/home/gapuchi";
          };
        };
      })
    ];
  };
}
