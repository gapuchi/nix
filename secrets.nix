let
  tintin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH5/4/MUW6RnFDUrPLQEDBNKz2ySF/Yy5Pfb/aHfF1NQ gapuchi@gapuchi-air.local";
  calculus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE03FhBuQe7q98s/JhnJj9LnNISVhw0hx14S6sLMx9uj root@nixos";
  gapuchiCalculus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN4+R9vr9Ww8Ci7h9XaxXRj6YDldv7KOOGc/D6cM/pOJ gapuchi@calculus";
in
{
  "secrets/discord-token.age".publicKeys = [
    tintin
    calculus
    gapuchiCalculus
  ];
  "secrets/grafana-key.age".publicKeys = [
    tintin
    calculus
    gapuchiCalculus
  ];
  "secrets/openclaw-gateway-env.age".publicKeys = [
    tintin
    calculus
    gapuchiCalculus
  ];
}
