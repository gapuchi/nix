os := `uname -s`
# darwin-rebuild fetches as root and then sets HOME=/var/root, so the user
# nix.conf is never read. sudo would also drop NIX_CONFIG from direnv.
switch_cmd := if os == "Darwin" { "sudo --preserve-env=NIX_CONFIG darwin-rebuild switch" } else { "sudo --preserve-env=NIX_CONFIG nixos-rebuild switch" }
version_cmd := if os == "Darwin" { "darwin-version" } else { "nixos-version" }

alias s := switch
alias u := update
alias c := check
alias v := version

update *inputs:
    nix flake update {{inputs}}

switch:
    {{switch_cmd}} --flake .

check:
    nix flake check --all-systems

version:
    {{version_cmd}} --configuration-revision
