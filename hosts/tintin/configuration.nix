{ ... }:
{
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "gapuchi"
    ];
  };

  nix.gc = {
    automatic = true;
    interval = {
      Weekday = 7;
      Hour = 3;
      Minute = 0;
    };
    options = "--delete-older-than 30d";
  };

  networking.hostName = "tintin";

  programs.zsh.enable = true;

  security.pam.enableSudoTouchIdAuth = true;

  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    NSGlobalDomain.ApplePressAndHoldEnabled = false;
    NSGlobalDomain.KeyRepeat = 2;
    NSGlobalDomain.InitialKeyRepeat = 15;
  };

  users.users.gapuchi = {
    name = "gapuchi";
    home = "/Users/gapuchi";
  };

  system.stateVersion = 5;
}
