{ ... }:
{
  flake.modules.homeManager.vscode =
    { pkgs, ... }:
    {
      programs.vscode = {
        enable = true;
        package = pkgs.code-cursor;
        profiles.default.extensions = with pkgs.vscode-extensions; [
          jnoortheen.nix-ide
          github.vscode-github-actions
          golang.go
          haskell.haskell
          ms-python.python
        ];
      };
    };
}
