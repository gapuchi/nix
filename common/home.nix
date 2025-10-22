{ pkgs, stateVersion, includeGuiPkgs, homeDirectory, ... }: {

  home = {
    username = "gapuchi";
    homeDirectory = homeDirectory;
    # The state version is required and should stay at the version you
    # originally installed.
    stateVersion = stateVersion;
  };

  home.packages = 
    let
      guiPkgs = with pkgs; [
        _1password-gui
        beeper
        code-cursor
        discord
        firefox
        google-chrome
        plex-desktop
        signal-desktop
        spotify
      ];
    in
      with pkgs; [
        awscli2
        fzf
        go
        graphite-cli
        rustup
        zellij
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
    settings.user = {
      name = "gapuchi";
      email = "arjun.adhia@gmail.com";
    };
  };

  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  programs.vscode = {
    enable = includeGuiPkgs;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      github.vscode-github-actions
      golang.go
      haskell.haskell
      ms-python.python
    ];
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "fzf" ];
    };

    initContent = ''
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

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
