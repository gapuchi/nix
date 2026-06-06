{ ... }:
{
  flake.modules.nixos.base =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.my.nixos;
    in
    {
      options.my.nixos = {
        hostName = lib.mkOption {
          type = lib.types.str;
        };
        authorizedKeys = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };
        stateVersion = lib.mkOption {
          type = lib.types.str;
          default = "25.11";
        };
        username = lib.mkOption {
          type = lib.types.str;
          default = "gapuchi";
        };
        homeDirectory = lib.mkOption {
          type = lib.types.str;
          default = "/home/gapuchi";
        };
        homeImports = lib.mkOption {
          type = lib.types.listOf lib.types.deferredModule;
          default = [ ];
        };
      };

      config = {
        networking.hostName = cfg.hostName;

        users.users.${cfg.username} = {
          isNormalUser = true;
          description = "Arjun Adhia";
          extraGroups = [
            "networkmanager"
            "wheel"
          ];
          shell = pkgs.zsh;
          openssh.authorizedKeys.keys = cfg.authorizedKeys;
        };

        programs.zsh.enable = true;

        nixpkgs.config.allowUnfree = true;

        services.openssh = {
          enable = true;
          settings.PasswordAuthentication = false;
          settings.KbdInteractiveAuthentication = false;
        };

        system.stateVersion = cfg.stateVersion;

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.${cfg.username} = {
            imports = cfg.homeImports;
            my.home.homeDirectory = cfg.homeDirectory;
          };
        };
      };
    };
}
