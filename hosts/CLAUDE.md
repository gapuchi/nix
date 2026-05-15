# Hosts

Hardware-specific NixOS files live here. **Machine configurations** (what to install, services, Home Manager) are in [`modules/machines/`](../modules/machines/).

For flakes, `just` commands, machine categories, and agenix secrets, see the root [`CLAUDE.md`](../CLAUDE.md).

## Layout

| Path | Role |
|------|------|
| `hosts/<hostname>/hardware-configuration.nix` | Disks, boot, kernel modules (often generated) |
| `modules/machines/<name>.nix` | Flake configuration for that machine |
| `modules/nixos/*.nix` | Shared NixOS feature modules |
| `modules/home/*.nix` | Shared Home Manager feature and bundle modules |

Flake output names match machine files: `calculus`, `haddock`, `gapuchi@tintin`, `arjun@arjun-gt`.

## Module tree

```
modules/
  home/              # Home Manager: features (git, vim, …) + bundles (gapuchi-terminal, gapuchi-desktop)
  nixos/             # NixOS features (caddy, pihole, …)
  machines/          # Per-machine flake configs (imports features + bundles)
  _lib/              # Shared non-module helpers
```

## Key machines

### `calculus` (Linux server)

Home server: Caddy, Pi-hole, Plex, monitoring, mafia-bot, etc. See `modules/machines/calculus.nix`. Home Manager uses `gapuchiTerminal`.

### `haddock` (Linux desktop)

NixOS workstation with GNOME. See `modules/machines/haddock.nix`. Home Manager uses `gapuchiDesktop`.

### `tintin` / `arjun-gt` (macOS)

Standalone Home Manager via `modules/machines/tintin.nix` and `modules/machines/arjun-gt.nix`. Both use `gapuchiTerminal`.

## Add a new site behind Caddy (`*.home.arpa`)

1. Pick an **unused** local port for the backend service.
2. Add a `reverse_proxy` in `modules/nixos/caddy.nix` for `<name>.home.arpa`.
3. Configure the service to listen on `127.0.0.1` at that port.
4. Wire the service in `modules/machines/calculus.nix` (or add a `modules/nixos/` module and import it).
5. Apply from the repo root: `just switch`.
