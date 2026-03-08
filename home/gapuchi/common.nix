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
    ../../modules/home-manager/direnv.nix
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/vim.nix
    ../../modules/home-manager/zsh.nix
  ];

  options = {
    my.home = {
      homeDirectory = lib.mkOption {
        type = lib.types.str;
        description = "Home directory for user";
      };

      stateVersion = lib.mkOption {
        type = lib.types.str;
        description = "State version";
      };
    };
  };

  config = {
    home = {
      username = "gapuchi";
      homeDirectory = cfg.homeDirectory;
      stateVersion = cfg.stateVersion;
    };

    home.packages = with pkgs; [
      awscli2
      fzf
      go
      gh
      graphite-cli
      nixfmt
      rustup
      zellij
    ];

    home.sessionPath = [
      "$HOME/.cargo/bin"
    ];

    programs.vscode = {
      enable = pkgs.stdenv.isLinux;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        github.vscode-github-actions
        golang.go
        haskell.haskell
        ms-python.python
      ];
    };

    # Let home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
