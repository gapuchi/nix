{ lib, osConfig, ... }:
{
  programs.openclaw = {
    enable = true;

    config = {
      gateway = {
        mode = "local";
        bind = "loopback";
        auth.mode = "token";
        trustedProxies = [
          "127.0.0.1/32"
          "::1/128"
        ];
        controlUi.allowedOrigins = [
          "https://openclaw.home.arpa"
        ];
      };

      agents.defaults = {
        model = {
          primary = "anthropic/claude-haiku-4-5";
          fallbacks = [ "anthropic/claude-sonnet-4-6" ];
        };
      };

      channels.discord = {
        enabled = true;
        groupPolicy = "allowlist";
        dmPolicy = "disabled";
        token = {
          source = "env";
          provider = "default";
          id = "DISCORD_BOT_TOKEN";
        };
        guilds."1489515613893431316" = {
          requireMention = false;
          ignoreOtherMentions = true;
          users = [ "331287244688195586" ];
        };
      };
    };

    skills = [ ];
  };

  # Workaround for openclaw/nix-openclaw#78: Home Manager symlinks into
  # /nix/store are rejected by the gateway's containment check.  Write
  # skill files as real copies instead.
  # https://github.com/openclaw/nix-openclaw/issues/78
  home.activation.openclawSkills =
    let
      skillsSrc = ./openclaw-skills;
      skillDirs = builtins.attrNames (
        lib.filterAttrs (_: type: type == "directory") (builtins.readDir skillsSrc)
      );
    in
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${lib.concatMapStringsSep "\n" (name: ''
        skill_dir="$HOME/.openclaw/workspace/skills/${name}"
        run mkdir -p "$skill_dir"
        run cp -f ${skillsSrc}/${name}/SKILL.md "$skill_dir/SKILL.md"
      '') skillDirs}
    '';

  systemd.user.services.openclaw-gateway = {
    Unit = {
      Wants = [ "network-online.target" ];
      After = [ "network-online.target" ];
    };
    Service = {
      EnvironmentFile = osConfig.age.secrets.openclaw-gateway-env.path;
      RestartSec = lib.mkForce "5s";
    };
  };
}
