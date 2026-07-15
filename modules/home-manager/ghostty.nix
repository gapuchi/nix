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
            "global:cmd+grave_accent=toggle_quick_terminal"
          ];
          quick-terminal-position = "bottom";
          quick-terminal-animation-duration = 0.1;
        };
      };
    };
}
