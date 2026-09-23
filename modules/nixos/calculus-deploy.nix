{ ... }:
{
  flake.modules.nixos.calculusDeploy =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      branch = "calculus";
      repoUrl = "https://github.com/gapuchi/nix";
      tagRef = "refs/tags/${branch}";
      # Exit 0 to deploy, 1 to skip, 255 when the check itself fails.
      # ExecCondition treats 1 as "skip", not a failed unit.
      mayDeploy = pkgs.writeShellApplication {
        name = "calculus-deploy-may-proceed";
        runtimeInputs = [ pkgs.gitMinimal ];
        text = ''
          current=$(/run/current-system/sw/bin/nixos-version --configuration-revision)

          case "$current" in
            "" | *-dirty)
              echo "Running a local/dirty build ($current); skipping to avoid overwriting local testing."
              exit 1
              ;;
          esac

          work=$(mktemp -d)
          trap 'rm -rf "$work"' EXIT

          git -C "$work" init -q
          git -C "$work" fetch -q "${repoUrl}" "${tagRef}:${tagRef}" || exit 255
          target=$(git -C "$work" rev-parse "${tagRef}^{commit}") || exit 255

          if [ "$current" = "$target" ]; then
            echo "Already at the ${branch} tag ($target); nothing to do."
            exit 1
          fi

          status=0
          git -C "$work" merge-base --is-ancestor "$current" "$target" 2>/dev/null || status=$?
          if [ "$status" -ne 0 ]; then
            echo "The ${branch} tag ($target) is not ahead of the running revision ($current); skipping."
            exit 1
          fi

          echo "The ${branch} tag moves forward ($current -> $target); deploying."
        '';
      };
    in
    {
      system.autoUpgrade = {
        enable = true;
        flake = "github:gapuchi/nix/${branch}";
        dates = "*:0/5";
        upgrade = false;
      };

      systemd.services.nixos-upgrade = {
        serviceConfig.ExecCondition = lib.getExe mayDeploy;
        environment.SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      };
    };
}
