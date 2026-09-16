{ ... }:
{
  flake.modules.homeManager.ghostty =
    { pkgs, ... }:
    {
      programs.ghostty = {
        enable = true;
        package =
          if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
        enableZshIntegration = true;
        settings = {
          theme = "Vercel";
          keybind = [
            "global:ctrl+grave_accent=toggle_quick_terminal"
          ];
          quick-terminal-position = "center";
          quick-terminal-animation-duration = 0.1;
          quick-terminal-size = "80%,70%";
        };
      };
    };
}
