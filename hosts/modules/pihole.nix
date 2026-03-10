{ pkgs, ... }:
{
  services.pihole-ftl = {
    enable = true;
  };

  services.pihole-web = {
    enable = true;
    ports = [ "443s" ];
  };
}
