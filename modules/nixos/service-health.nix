{ ... }:
let
  port = 8083;
  units = [
    "mafia-bot"
    "league-bot"
  ];
in
{
  flake.modules.nixos.serviceHealth =
    { pkgs, ... }:
    let
      unitsPy = builtins.concatStringsSep ", " (map (u: "\"${u}\"") units);
      server = pkgs.writers.writePython3Bin "service-health" { flakeIgnore = [ "E501" ]; } ''
        import http.server
        import socketserver
        import subprocess

        UNITS = set([${unitsPy}])
        PORT = ${toString port}


        def is_active(unit):
            result = subprocess.run(
                ["systemctl", "is-active", unit],
                capture_output=True,
                text=True,
            )
            return result.stdout.strip() == "active"


        class Handler(http.server.BaseHTTPRequestHandler):
            def respond(self, with_body):
                unit = self.path.lstrip("/")
                if unit not in UNITS:
                    self.send_response(404)
                    self.end_headers()
                    return
                active = is_active(unit)
                self.send_response(200 if active else 503)
                self.send_header("Content-Type", "text/plain")
                self.end_headers()
                if with_body:
                    self.wfile.write(b"up\n" if active else b"down\n")

            def do_HEAD(self):
                self.respond(False)

            def do_GET(self):
                self.respond(True)

            def log_message(self, *args):
                pass


        with socketserver.TCPServer(("127.0.0.1", PORT), Handler) as httpd:
            httpd.serve_forever()
      '';
    in
    {
      systemd.services.service-health = {
        description = "HTTP health endpoint for systemd units";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        path = [ pkgs.systemd ];
        serviceConfig = {
          ExecStart = "${server}/bin/service-health";
          DynamicUser = true;
          Restart = "on-failure";
        };
      };
    };
}
