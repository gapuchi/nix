{ inputs, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    {
      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.just
          inputs.agenix.packages.${system}.default
        ];
      };
    };
}
