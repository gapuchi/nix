{ ... }:
{
  flake.modules.homeManager.base =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      cfg = config.my.home;
    in
    {
      options.my.home = {
        username = lib.mkOption {
          type = lib.types.str;
          default = "gapuchi";
        };
        homeDirectory = lib.mkOption {
          type = lib.types.str;
        };
        git = {
          name = lib.mkOption {
            type = lib.types.str;
            default = "gapuchi";
          };
          email = lib.mkOption {
            type = lib.types.str;
            default = "arjun.adhia@gmail.com";
          };
        };
      };

      config = {
        home = {
          username = cfg.username;
          homeDirectory = cfg.homeDirectory;
          stateVersion = "25.05";
        };
        home.packages = with pkgs; [
          btop
          claude-code
          fastfetch
          fzf
          gh
          jq
          just-lsp
          nixd
          nixfmt
          nixfmt-tree
          rustup
          zellij
        ];
        home.sessionPath = [ "$HOME/.cargo/bin" ];
        programs.home-manager.enable = true;
      };
    };
}
