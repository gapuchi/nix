{ pkgs, config, ... }:
let
  cfg = config.my.home;
in
{
  programs.ghostty = {
    enable = cfg.hasGui;
    enableZshIntegration = true;
    settings = {
      theme = "vercel";
    };
  };
}
