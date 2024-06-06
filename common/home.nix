{ pkgs, stateVersion, includeGuiPkgs, ... }: {

  home.username = "gapuchi";
  home.homeDirectory = "/home/gapuchi";

  home.packages = 
    let
      guiPkgs = with pkgs; [
        _1password-gui
        beeper
        discord
        google-chrome
        signal-desktop
        spotify
      ];
    in
      with pkgs; [
        awscli2
        fzf
        go
        rustup
        tmux
      ] ++ (if includeGuiPkgs then guiPkgs else []);

  home.sessionPath = [
    "$HOME/.cargo/bin"
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    userName = "gapuchi";
    userEmail = "arjun.adhia@gmail.com";
  };

  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      github.vscode-github-actions
      golang.go
    ];
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "tmux" "fzf" ];
    };

    initExtra = ''
      [[ ! -f ${./p10k.zsh} ]] || source ${./p10k.zsh}
    '';

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];
  };

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = stateVersion;

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
