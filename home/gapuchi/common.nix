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
    };
  };

  config = {
    home = {
      username = "gapuchi";
      homeDirectory = cfg.homeDirectory;
      stateVersion = "25.05";
    };

    home.packages = with pkgs; [
      awscli2
      fzf
      go
      gh
      graphite-cli
      just
      just-lsp # TODO For VS Code
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
