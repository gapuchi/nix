{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.home;
in
{
  imports = [
    ./modules/direnv.nix
    ./modules/ghostty.nix
    ./modules/git.nix
    ./modules/vim.nix
    ./modules/vscode.nix
    ./modules/zsh.nix
  ];

  options = {
    my.home = {
      homeDirectory = lib.mkOption {
        type = lib.types.str;
        description = "Home directory for user";
      };

      hasGui = lib.mkOption {
        type = lib.types.bool;
        description = "Does the machine have a desktop env";
        default = false;
      };
    };
  };

  config = {
    home = {
      username = "gapuchi";
      homeDirectory = cfg.homeDirectory;
      stateVersion = "25.05";
    };

    home.packages = with pkgs; [
      claude-code
      fzf
      gh
      graphite-cli
      jq
      nixfmt
      rustup
      zellij
    ];

    home.sessionPath = [
      "$HOME/.cargo/bin"
    ];

    programs.home-manager.enable = true;
  };
}
