# Hosts

Hardware-specific NixOS files live here. **Machine configurations** (flake outputs) are in [`modules/hosts/`](../modules/hosts/).

For the module-library/host-wiring split, the `my.*` contract, `just` commands, and agenix secrets, see the root [`AGENTS.md`](../AGENTS.md).

## Layout

| Path | Role |
|------|------|
| `hosts/<hostname>/hardware-configuration.nix` | Disks, boot, kernel modules (NixOS only; often generated) |
| `modules/hosts/<hostname>/default.nix` | Flake output wiring for that machine |

A host file builds one output (`nixosSystem` / `darwinSystem` / `homeManagerConfiguration`), pulls registered modules from `config.flake.modules.*`, and sets `my.*`. Output names match the host directory: `calculus`, `haddock`, `tintin`, `arjun@arjun-gt`.

## Key machines

### `calculus` (Linux server)

Home server: `gapuchiServer` bundle plus `caddy`, `plex`, `pihole`, `mafiaBot`, `worldCupBot`, `monitoring`, `tailscale`, `uptimeKuma`. Home Manager uses `gapuchiTerminal` (via `gapuchiServer`). See `modules/hosts/calculus/default.nix`.

### `haddock` (Linux desktop)

NixOS workstation with GNOME via `gapuchiLinuxDesktop` (Home Manager `gapuchiDesktop`) + `tailscale`. See `modules/hosts/haddock/default.nix`.

### `tintin` (macOS)

nix-darwin (`darwinConfigurations.tintin`) using `gapuchiBase`, `gapuchiDefaults`, and Home Manager `gapuchiTerminal`. See `modules/hosts/tintin/default.nix`.

### `arjun-gt` (macOS)

Standalone Home Manager (`homeConfigurations."arjun@arjun-gt"`) using `gapuchiTerminal`, with a per-user `age.secrets` override. See `modules/hosts/arjun-gt/default.nix`.

## Add a new site behind Caddy

Caddy on `calculus` serves `*.lab.adhia.net` with a Let's Encrypt cert via Cloudflare DNS-01 (token in the `caddy-dns-token` secret). 80/443 are only reachable over Tailscale.

1. Pick an **unused** local port for the backend service and configure it to listen on `localhost:<port>`.
2. Add a `virtualHosts."<name>.lab.adhia.net".extraConfig` in `modules/nixos/caddy.nix` with `reverse_proxy localhost:<port>` and the shared `${tls}` block.
3. Wire the service: extend `modules/hosts/calculus/default.nix`, or add a `modules/nixos/<svc>.nix` and import it there.
4. Apply from the repo root: `just switch`.
