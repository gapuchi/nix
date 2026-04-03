# Hosts

This directory contains **NixOS** host configurations: per-machine `configuration.nix` under `hosts/<hostname>/` and shared modules under `hosts/modules/`.

For flakes, `just` commands, machine categories (server vs desktop), and agenix secrets, see the root [`AGENTS.md`](../AGENTS.md).

## Layout

| Path | Role |
|------|------|
| `hosts/<hostname>/configuration.nix` | Main system config for that machine |
| `hosts/<hostname>/hardware-configuration.nix` | Hardware / disks (often generated) |
| `hosts/modules/*.nix` | Shared NixOS modules; imported by hosts that need them |

Flake `nixosConfigurations` names in `flake.nix` match these hostnames (e.g. `calculus`, `gapuchi-desktop`).

## Key machines

### `calculus` (Linux server)

Home server: long-running services, reasonably hardened. Uses **Caddy** (`modules/caddy.nix`) as the reverse proxy for HTTP(S). **Pi-hole** (`modules/pihole.nix`) provides DNS for `*.home.arpa` so names resolve to this host; **Caddy** then serves those hostnames on the machine. Prefer that pattern over opening arbitrary ports on the WAN.

This host uses **agenix** and Home Manager with `home/gapuchi/linux-headless.nix`. Treat it as the **Linux server** category in root `AGENTS.md`.

### `gapuchi-desktop` (Linux desktop)

NixOS workstation. Imports only its own `hardware-configuration.nix` in `configuration.nix` (no `hosts/modules/` stack from calculus). Home Manager uses `home/gapuchi/linux.nix`.

## Shared modules (`hosts/modules/`)

Used by **calculus** today (see `hosts/calculus/configuration.nix` imports). One-line map:

| Module | Purpose |
|--------|---------|
| `caddy.nix` | Reverse proxy for `*.home.arpa` (and related sites) |
| `pihole.nix` | Pi-hole DNS (and DHCP if configured there) |
| `plex.nix` | Plex and Tautulli |
| `mafia-bot.nix` | Mafia bot service (flake input `mafia-bot`) |
| `monitoring.nix` | Prometheus, Grafana, exporters |
| `tailscale.nix` | Tailscale |
| `uptime-kuma.nix` | Uptime Kuma |

## Add a new site behind Caddy (`*.home.arpa`)

1. Pick an **unused** local port for the backend service.
2. Add a `reverse_proxy` (or equivalent) in `modules/caddy.nix` for `<name>.home.arpa` pointing at that port.
3. Configure the **service** to listen on `127.0.0.1` (or the interface/port Caddy targets), matching patterns in existing modules.
4. If the service is new, add or import its module in `hosts/calculus/configuration.nix` and wire firewall/listen options like sibling services.
5. Apply from the repo root: `just switch`.
