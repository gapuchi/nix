{
  inputs,
  config,
  ...
}:

let
  hmMods = config.flake.modules.homeManager;
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
              name = "arjun";
              email = "arjun.adhia@graphite.com";
            };
          };

          programs.mise.enable = true;

          age.secrets.arjun-gt-initContent.file = ../../secrets/arjun-gt-initContent;

          programs.zsh.initContent = lib.mkAfter ''
            [[ -f ${config.age.secrets.arjun-gt-initContent.path} ]] && \
              source ${config.age.secrets.arjun-gt-initContent.path}
          '';
        }
      )
    ];
  };
}
