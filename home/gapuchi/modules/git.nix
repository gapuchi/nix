{ config, ... }:
let
  cfg = config.my.home.git;
in
{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = cfg.name;
        email = cfg.email;
      };

      pull = {
        rebase = true;
      };
    };
  };
}
