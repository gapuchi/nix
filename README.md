# Nix Config

This repo contains my configuration for Nix for my devices. It utilizes Flakes + Home Manager to install my user applications.

Encrypted secrets and private evaluation-time values come from the private flake [`gapuchi/nix-private`](https://github.com/gapuchi/nix-private). Nix needs a GitHub token with read access to that repo (`access-tokens = github.com=<PAT>` in `nix.conf`).

## Quick Start

Flake Update

```bash
just update # u
```

Rebuild + Switch

```bash
just switch # s
```
