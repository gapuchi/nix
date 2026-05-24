let
  sshKeys = import ./modules/_lib/ssh-keys.nix;
in
{
  "secrets/mafia-bot-discord-token.age".publicKeys = with sshKeys; [
    tintin
    rootCalculus
    calculus
  ];
}
