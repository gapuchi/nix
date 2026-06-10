os := `uname -s`
switch_cmd := if os == "Darwin" { "sudo darwin-rebuild switch" } else { "sudo nixos-rebuild switch" }
version_cmd := if os == "Darwin" { "darwin-version" } else { "nixos-version" }

alias s := switch
alias u := update
alias c := check
alias v := version

update:
    nix flake update

switch:
    {{switch_cmd}} --flake .

check:
    nix flake check --all-systems

version:
    {{version_cmd}} --configuration-revision