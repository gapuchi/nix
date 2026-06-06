{ ... }:
{
  flake.modules.darwin.gapuchiDefaults = {
    time.timeZone = "America/New_York";

    system.defaults = {
      dock = {
        autohide = true;
        tilesize = 45;
        orientation = "left";
        wvous-br-corner = 14; # Quick Note
        persistent-apps = [
          { app = "/System/Applications/Messages.app"; }
        ];
        persistent-others = [
          {
            folder = {
              path = "/Users/gapuchi/Downloads";
              arrangement = "date-added";
              showas = "fan";
            };
          }
        ];
      };

      trackpad = {
        TrackpadRightClick = true;
        TrackpadThreeFingerTapGesture = 0;
        TrackpadFourFingerPinchGesture = 2;
        TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;
      };

      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleIconAppearanceTheme = "RegularDark";
      };

      WindowManager.EnableTilingOptionAccelerator = false;

      CustomUserPreferences."com.apple.finder".FXPreferredViewStyle = "glyv";
    };
  };
}
