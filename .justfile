alias s := switch
alias u := update

update:
    nix flake update

switch:
    home-manager switch --flake .