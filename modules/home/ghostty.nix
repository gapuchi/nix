{ ... }:
{
  flake.modules.homeManager.ghostty = { ... }: {
    programs.ghostty = {
      enable = true;
      enableZshIntegration = true;
      settings.theme = "Vercel";
    };
  };
}
