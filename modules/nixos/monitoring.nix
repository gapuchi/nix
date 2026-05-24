{ ... }:
{
  flake.modules.nixos.monitoring =
    { pkgs, lib, ... }:
    {
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "netdata" ];

      services.netdata = {
        enable = true;
        package = pkgs.netdata.override { withCloudUi = true; };
        config = {
          global = {
            "memory mode" = "dbengine";
            "update every" = 2;
          };
          web = {
            "bind to" = "127.0.0.1";
            "default port" = 19999;
          };
        };
      };
    };
}
