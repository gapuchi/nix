# Nix Config

This repo contains my configuration for Nix for my devices. It utilizes Flakes + Home Manager to install my user applications.

## Bootstrap A New Device

Note: This is only for NixOS.

Pre-Req: Set up GitHub access to this repo on the device.

```bash
git clone git@github.com:gapuchi/nix.git .nix
cd .nix/machines
mkdir $HOST
cd $HOST
cp /etc/nixos/*.nix .
sudo rm /etc/nixos/*.nix
sudo ln -s ~/.nix/flake.nix /etc/nixos/flake.nix
sudo nixos-rebuild switch
```

## Improvements

- [ ] Support `nix-darwin`
- [ ] Automate the ssh setup for GitHub access
