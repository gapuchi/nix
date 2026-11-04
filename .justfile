os := `uname -s`
rebuild := if os == "Darwin" { "darwin-rebuild" } else { "nixos-rebuild" }
version_cmd := if os == "Darwin" { "darwin-version" } else { "nixos-version" }

alias s := switch
alias u := update
alias c := check
alias v := version

update *inputs:
    nix flake update {{inputs}}

# sudo drops the environment; pass NIX_CONFIG through so a token from
# .envrc.local (or the shell) can fetch inputs.nix-private on NixOS and Darwin.
switch:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ -n "${NIX_CONFIG:-}" ]]; then
      sudo env NIX_CONFIG="$NIX_CONFIG" {{rebuild}} switch --flake .
    else
      sudo {{rebuild}} switch --flake .
    fi

check:
    nix flake check --all-systems

version:
    {{version_cmd}} --configuration-revision
