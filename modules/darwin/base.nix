{ inputs, ... }:
{
  flake.modules.darwin.base =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.my.darwin;
    in
    {
      options.my.darwin = {
        hostName = lib.mkOption {
          type = lib.types.str;
        };
        username = lib.mkOption {
          type = lib.types.str;
          default = "gapuchi";
        };
        homeDirectory = lib.mkOption {
          type = lib.types.str;
          default = "/Users/gapuchi";
        };
        homeImports = lib.mkOption {
          type = lib.types.listOf lib.types.deferredModule;
          default = [ ];
        };
      };

      config = {
        networking.hostName = cfg.hostName;

        users.users.${cfg.username} = {
          home = cfg.homeDirectory;
          shell = pkgs.zsh;
        };

        programs.zsh.enable = true;

        nixpkgs.config.allowUnfree = true;

        # Determinate manages the Nix install and /etc/nix/nix.conf.
        nix.enable = false;

        system.stateVersion = 6;
        system.primaryUser = cfg.username;

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "hm-bak";
          extraSpecialArgs = { inherit inputs; };
          users.${cfg.username} = {
            imports = cfg.homeImports;
            my.home.homeDirectory = cfg.homeDirectory;
          };
        };
      };
    };
}
