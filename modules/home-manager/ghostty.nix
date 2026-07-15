{ ... }:
{
  flake.modules.homeManager.ghostty =
    { ... }:
    {
      programs.ghostty = {
        enable = true;
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
