{ ... }:
{
  flake.modules.nixos.calculusDeploy =
    { ... }:
    {
      system.autoUpgrade = {
        enable = true;
        flake = "github:gapuchi/nix/calculus";
        dates = "*:0/5";
        upgrade = false;
      };
    };
}
