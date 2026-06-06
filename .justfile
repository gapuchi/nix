os := `uname -s`
switch_cmd := if os == "Darwin" { "home-manager switch" } else { "sudo nixos-rebuild switch" }
alias s := switch
alias u := update
alias c := check

update:
    nix flake update

switch:
    {{switch_cmd}} --flake .

check:
    nix flake check --all-systems