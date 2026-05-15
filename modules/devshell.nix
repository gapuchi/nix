{ inputs, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    {
      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.git
          pkgs.just
          inputs.agenix.packages.${system}.default
        ];
      };
    };
}
