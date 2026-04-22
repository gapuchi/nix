{ pkgs, ... }:
{
  imports = [ ./common.nix ];

  my.home = {
    username = "arjun";
    homeDirectory = "/Users/arjun";
    git = {
      name = "arjun";
      email = "arjun.adhia@graphite.com";
    };
  };

  programs.mise.enable = true;
}
