{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    mafia-bot = {
      url = "github:gapuchi/mafia-bot-rust";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    world-cup-bot = {
      url = "github:gapuchi/world-cup-bot";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        crane.follows = "mafia-bot/crane";
        utils.follows = "mafia-bot/utils";
      };
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
