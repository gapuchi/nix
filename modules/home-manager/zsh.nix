{ pkgs, ... }: {
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
}