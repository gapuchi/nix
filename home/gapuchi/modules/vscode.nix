{ pkgs, config, ... }:
let
  cfg = config.my.home;
in
{
  home.packages = with pkgs; [
    just-lsp # TODO We do not need this for headless
  ];

  programs.vscode = {
    enable = cfg.hasGui;
    package = pkgs.code-cursor;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      github.vscode-github-actions
      golang.go
      haskell.haskell
      ms-python.python
    ];
  };
}
