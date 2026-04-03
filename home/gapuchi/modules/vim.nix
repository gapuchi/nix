{ pkgs, ... }:
{
  programs.vim = {
    enable = true;
    defaultEditor = true;
    extraConfig = "
      :syntax on
    ";
  };
}
