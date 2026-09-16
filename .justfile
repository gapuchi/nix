os := `uname -s`
switch_cmd := if os == "Darwin" { "sudo darwin-rebuild switch" } else { "sudo nixos-rebuild switch" }
version_cmd := if os == "Darwin" { "darwin-version" } else { "nixos-version" }

alias s := switch
alias u := update
alias c := check
alias v := version
alias dc := deploy-calculus

update *inputs:
    nix flake update {{inputs}}

switch:
    {{switch_cmd}} --flake .

check:
    nix flake check --all-systems

version:
    {{version_cmd}} --configuration-revision

deploy-calculus:
    git tag -f calculus
    git push -f origin refs/tags/calculus