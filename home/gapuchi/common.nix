{ pkgs, lib, ... }: {
  imports = [
    ../../modules/home-manager/direnv.nix
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/vim.nix
    ../../modules/home-manager/zsh.nix
  ];

  home = {
    username = "gapuchi";
    homeDirectory = lib.mkDefault "/home/gapuchi";
    stateVersion = "25.05";
  };

  home.packages = with pkgs; [
    awscli2
    fzf
    go
    gh
    graphite-cli
    rustup
    zellij
  ];

  home.sessionPath = [
    "$HOME/.cargo/bin"
  ];

  programs.vscode = {
    enable = pkgs.stdenv.isLinux;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      github.vscode-github-actions
      golang.go
      haskell.haskell
      ms-python.python
    ];
  };

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}