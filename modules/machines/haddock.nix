{ inputs, config, ... }:

let
  hmMods = config.flake.modules.homeManager;
  nixosMods = config.flake.modules.nixos;
  sshKeys = import ../_lib/ssh-keys.nix;
in
{
  flake.nixosConfigurations.haddock = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      ../../hosts/haddock/hardware-configuration.nix
      inputs.home-manager.nixosModules.home-manager
      nixosMods.tailscale
      ({ pkgs, ... }: {
        boot.loader = {
          systemd-boot = {
            enable = true;
            extraInstallCommands = ''
              ${pkgs.gnused}/bin/sed -i 's/^default.*$/default @saved/' /boot/loader/loader.conf
            '';
          };
          efi.canTouchEfiVariables = true;
        };

        networking.hostName = "haddock";
        networking.networkmanager.enable = true;

        time.timeZone = "America/New_York";
        time.hardwareClockInLocalTime = true;

        i18n.defaultLocale = "en_US.UTF-8";
        i18n.extraLocaleSettings = {
          LC_ADDRESS = "en_US.UTF-8";
          LC_IDENTIFICATION = "en_US.UTF-8";
          LC_MEASUREMENT = "en_US.UTF-8";
          LC_MONETARY = "en_US.UTF-8";
          LC_NAME = "en_US.UTF-8";
          LC_NUMERIC = "en_US.UTF-8";
          LC_PAPER = "en_US.UTF-8";
          LC_TELEPHONE = "en_US.UTF-8";
          LC_TIME = "en_US.UTF-8";
        };

        services.xserver = {
          enable = true;
          videoDrivers = [ "amdgpu" ];
          xkb = {
            layout = "us";
            variant = "";
          };
        };
        services.displayManager.gdm.enable = true;
        services.desktopManager.gnome.enable = true;
        services.printing.enable = true;

        services.pulseaudio.enable = false;
        security.rtkit.enable = true;
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
        };

        users.users.gapuchi = {
          isNormalUser = true;
          description = "Arjun Adhia";
          extraGroups = [
            "networkmanager"
            "wheel"
          ];
          shell = pkgs.zsh;
          openssh.authorizedKeys.keys = with sshKeys; [
            calculus
            tintin
          ];
        };

        nix = {
          package = pkgs.nixVersions.stable;
          extraOptions = ''
            experimental-features = nix-command flakes
          '';
        };

        nixpkgs.config.allowUnfree = true;

        environment.systemPackages = with pkgs; [
          vim
          gcc
        ];

        programs.zsh.enable = true;

        services.openssh = {
          enable = true;
          settings.PasswordAuthentication = false;
          settings.KbdInteractiveAuthentication = false;
        };

        networking.firewall.allowedTCPPorts = [ 22 8081 ];

        system.stateVersion = "25.11";

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.gapuchi = {
            imports = with hmMods; [ gapuchiDesktop ];
            my.home.homeDirectory = "/home/gapuchi";
          };
        };
      })
    ];
  };
}
