{ ... }:
{
  flake.modules.nixos.homeAssistant = {
    services.home-assistant = {
      enable = true;
      extraComponents = [
        "analytics"
        "cast"
        "google_translate"
        "met"
        "radio_browser"
        "shopping_list"
        "isal"
        "tplink"
      ];
      config = {
        default_config = { };
      };
    };
  };
}
