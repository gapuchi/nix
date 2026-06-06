{ config, ... }:
let
  hmMods = config.flake.modules.homeManager;
  nixosMods = config.flake.modules.nixos;
in
{
  flake.modules.nixos.gapuchiLinuxDesktop = { pkgs, ... }: {
    imports = with nixosMods; [ gapuchiLinuxBase ];

    my.nixos.homeImports = with hmMods; [ gapuchiDesktop ];

    boot.loader.systemd-boot.extraInstallCommands = ''
      ${pkgs.gnused}/bin/sed -i 's/^default.*$/default @saved/' /boot/loader/loader.conf
    '';

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

    nix = {
      package = pkgs.nixVersions.stable;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };

    environment.systemPackages = with pkgs; [
      vim
      gcc
    ];
  };
}
