{ pkgs, ... }:
{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "gapuchi";
        email = "arjun.adhia@gmail.com";
      };

      pull = {
        rebase = true;
      };
    };
  };
}
