{ ... }:
{
  flake.modules.nixos.calculusDeploy =
    {
      config,
      pkgs,
      ...
    }:
    let
      branch = "calculus";
      flakeRef = "github:gapuchi/nix/${branch}";
      repoUrl = "https://github.com/gapuchi/nix";
      tagRef = "refs/tags/${branch}";
    in
    {
      systemd.services.calculus-deploy = {
        description = "Deploy the ${branch} tag, but only when it fast-forwards the running system";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];

        path = [
          pkgs.gitMinimal
          config.system.build.nixos-rebuild
          config.nix.package.out
        ];

        environment.SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

        serviceConfig.Type = "oneshot";

        script = ''
          set -euo pipefail

          current=$(/run/current-system/sw/bin/nixos-version --configuration-revision)

          case "$current" in
            "" | *-dirty)
              echo "Running a local/dirty build ($current); skipping to avoid overwriting local testing."
              exit 0
              ;;
          esac

          work=$(mktemp -d)
          trap 'rm -rf "$work"' EXIT

          git -C "$work" init -q
          git -C "$work" fetch -q ${repoUrl} "${tagRef}:${tagRef}"
          target=$(git -C "$work" rev-parse "${tagRef}^{commit}")

          if [ "$current" = "$target" ]; then
            echo "Already at the ${branch} tag ($target); nothing to do."
            exit 0
          fi

          if ! git -C "$work" merge-base --is-ancestor "$current" "$target" 2>/dev/null; then
            echo "The ${branch} tag ($target) is not ahead of the running revision ($current); skipping."
            exit 0
          fi

          echo "The ${branch} tag moves forward ($current -> $target); deploying."
          exec nixos-rebuild switch --flake "${flakeRef}"
        '';
      };

      systemd.timers.calculus-deploy = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*:0/5";
          Persistent = true;
        };
      };
    };
}
