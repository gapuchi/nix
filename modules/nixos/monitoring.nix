{ ... }:
{
  flake.modules.nixos.monitoring =
    { pkgs, config, ... }:
    {
      age.secrets.grafana-key = {
        file = ../../secrets/grafana-key.age;
        owner = "grafana";
        group = "grafana";
      };

      services.prometheus = {
        enable = true;
        exporters.node = {
          enable = true;
          port = 9000;
          enabledCollectors = [
            "ethtool"
            "softirqs"
            "systemd"
            "tcpstat"
          ];
          extraFlags = [
            "--collector.ntp.protocol-version=4"
            "--no-collector.mdadm"
          ];
        };
        scrapeConfigs = [
          {
            job_name = "node-exporter";
            static_configs = [ { targets = [ "127.0.0.1:9000" ]; } ];
          }
        ];
      };

      services.grafana = {
        enable = true;
        provision = {
          enable = true;
          datasources.settings.datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              url = "http://localhost:9090";
            }
          ];
          dashboards.settings.providers = [
            {
              name = "Default";
              options.path = "/var/lib/grafana/dashboards";
            }
          ];
        };
        settings = {
          security.secret_key = "$__file{${config.age.secrets.grafana-key.path}}";
          server = {
            http_addr = "127.0.0.1";
            http_port = 3000;
            enable_gzip = true;
          };
          analytics.reporting_enabled = false;
        };
      };

      systemd.tmpfiles.rules = [
        "d /var/lib/grafana/dashboards 0755 grafana grafana -"
        "L+ /var/lib/grafana/dashboards/node-exporter.json - - - - ${
          pkgs.fetchurl {
            url = "https://grafana.com/api/dashboards/1860/revisions/42/download";
            sha256 = "sha256-pNgn6xgZBEu6LW0lc0cXX2gRkQ8lg/rer34SPE3yEl4=";
          }
        }"
      ];
    };
}
