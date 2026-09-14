{ ... }:
{
  flake.modules.nixos.cachix =
    { ... }:
    {
      nix.settings = {
        substituters = [ "https://gapuchi.cachix.org" ];
        trusted-public-keys = [
          "gapuchi.cachix.org-1:pBIYxprn1HJN4swjBlgEz58cOwxVGsXhTB6j6TqwAOI="
        ];
      };
    };
}
