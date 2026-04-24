{ config, osConfig, ... }:
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
        token = {
          source = "env";
          provider = "default";
          id = "DISCORD_BOT_TOKEN";
        };
        guilds."1489515613893431316".requireMention = true;
      };
    };
  };

  systemd.user.services.openclaw-gateway.Service.EnvironmentFile =
    osConfig.age.secrets.openclaw-gateway-env.path;
}
