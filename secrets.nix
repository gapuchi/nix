let
  sshKeys = import ./modules/_lib/ssh-keys.nix;
in
{
  "secrets/mafia-bot-discord-token.age".publicKeys = with sshKeys; [
    tintin
    rootCalculus
    calculus
  ];
  "secrets/world-cup-bot.env.age".publicKeys = with sshKeys; [
    tintin
    rootCalculus
    calculus
  ];
  "secrets/caddy-dns-token.age".publicKeys = with sshKeys; [
    tintin
    rootCalculus
    calculus
  ];
  "secrets/arjun-gt-initContent.age".publicKeys = with sshKeys; [ arjunGt ];
}
