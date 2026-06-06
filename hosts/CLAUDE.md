# Hosts

Hardware-specific NixOS files live here. **Machine configurations** (flake outputs) are in [`modules/hosts/`](../modules/hosts/).

For flakes, `just` commands, machine categories, and agenix secrets, see the root [`CLAUDE.md`](../CLAUDE.md).

## Layout

| Path | Role |
|------|------|
| `hosts/<hostname>/hardware-configuration.nix` | Disks, boot, kernel modules (NixOS only; often generated) |
| `modules/hosts/<hostname>/default.nix` | Flake configuration for that machine |
| `modules/nixos/*.nix` | Shared NixOS feature modules |
| `modules/darwin/*.nix` | Shared nix-darwin feature and bundle modules |
| `modules/home-manager/*.nix` | Shared Home Manager feature and bundle modules |

Flake output names match host directories: `calculus`, `haddock`, `tintin`, `arjun@arjun-gt`.

## Module tree

```
hosts/
  <hostname>/
    hardware-configuration.nix  # NixOS hardware (when applicable)

modules/
  hosts/         # per-machine flake output wiring
  home-manager/  # Home Manager: features (git, vim, …) + bundles (gapuchi-terminal, gapuchi-desktop)
  nixos/         # NixOS features (caddy, pihole, …)
  darwin/        # nix-darwin: base + bundles (gapuchi-base, gapuchi-defaults)
  _lib/          # Shared non-module helpers
```

`flake.nix` auto-imports all `modules/**/*.nix` via import-tree.

## Key machines

### `calculus` (Linux server)

Home server: Caddy, Pi-hole, Plex, monitoring, mafia-bot, etc. See `modules/hosts/calculus/default.nix`. Home Manager uses `gapuchiTerminal`.

### `haddock` (Linux desktop)

NixOS workstation with GNOME. See `modules/hosts/haddock/default.nix`. Home Manager uses `gapuchiDesktop`.

### `tintin` (macOS)

nix-darwin via `modules/hosts/tintin/default.nix` (`darwinConfigurations.tintin`). Uses `gapuchiBase`, `gapuchiDefaults`, and Home Manager `gapuchiTerminal`.

### `arjun-gt` (macOS)

Standalone Home Manager via `modules/hosts/arjun-gt/default.nix`. Uses `gapuchiTerminal`.

## Add a new site behind Caddy (`*.home.arpa`)

1. Pick an **unused** local port for the backend service.
2. Add a `reverse_proxy` in `modules/nixos/caddy.nix` for `<name>.home.arpa`.
3. Configure the service to listen on `127.0.0.1` at that port.
4. Wire the service in `modules/hosts/calculus/default.nix` (or add a `modules/nixos/` module and import it).
5. Apply from the repo root: `just switch`.
