{ config, ... }:
{
  age.secrets = {
    gateway-token = {
      file = ../../secrets/gateway-token.age;
      owner = "openclaw";
      group = "openclaw";
      mode = "0600";
    };

    anthropic-api = {
      file = ../../secrets/openclaw-env.age;
      owner = "openclaw";
      group = "openclaw";
      mode = "0600";
    };
  };

  services.openclaw = {
    enable = true;
    gatewayPort = 3002;
    gatewayAuthTokenFile = config.age.secrets.gateway-token.path;
    anthropicApiKeyFile = config.age.secrets.anthropic-api.path;
    controlUiAllowedOrigins = [
      "https://openclaw.home.arpa"
      "127.0.0.1"
      "::1"
    ];
  };
}
