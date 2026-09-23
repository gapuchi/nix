{ inputs, ... }:
{
  flake.modules.nixos.rummy =
    { ... }:
    {
      imports = [ inputs.rummy.nixosModules.default ];

      services.points-rummy = {
        enable = true;
        port = 3000;
      };
    };
}
