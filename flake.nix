{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }: {
    packages."aarch64-darwin".default = let
      pkgs = import nixpkgs {
        system = "aarch64-darwin";
        config.allowUnfree = true;
      };
    in
    pkgs.buildEnv {
      name = "home-packages";
      paths = with pkgs; [
        awscli
        fzf
        git
        go
        golangci-lint
        jetbrains.goland
        localstack
        tmux
        vscode
      ];
    };
  };

}