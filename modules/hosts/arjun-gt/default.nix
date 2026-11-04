{
  inputs,
  config,
  ...
}:

let
  hmMods = config.flake.modules.homeManager;
  identity = inputs.nix-private.identity;
in
{
  flake.homeConfigurations."arjun@arjun-gt" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
    modules = with hmMods; [
      gapuchiTerminal
      inputs.agenix.homeManagerModules.default
      (
        { config, lib, ... }:
        {
          nixpkgs.config.allowUnfree = true;

          my.home = {
            username = "arjun";
            homeDirectory = "/Users/arjun";
            git = {
              name = identity.git.work.name;
              email = identity.git.work.email;
            };
          };

          age.secrets.arjun-gt-initContent.file = "${inputs.nix-private}/secrets/arjun-gt-initContent.age";

          programs.zsh.initContent = lib.mkAfter ''
            [[ -f ${config.age.secrets.arjun-gt-initContent.path} ]] && \
              source ${config.age.secrets.arjun-gt-initContent.path}
          '';
        }
      )
    ];
  };
}
