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

Home server. `modules/hosts/calculus/default.nix` selects `gapuchiServer` and the lab modules. Those lab modules are single-host features selected only here.

Snowy (`devices.snowy`) is the NFS library, mounted here and on haddock at the same path. qBittorrent runs inside the Mullvad namespace (`vpnNamespaces.mullvad`): a dropped tunnel has no route out, and Caddy reaches the WebUI at `192.168.15.1:8090` because port mappings are PREROUTING-only. The arr apps stay on the host network and import from that download directory. Tdarr's server runs here; the worker is on haddock, so nothing transcodes while that PC is off.

### `haddock` (Linux desktop)

NixOS workstation with GNOME via `gapuchiLinuxDesktop` (Home Manager `gapuchiTerminal` + `gapuchiDesktop`), plus `tailscale` and `tdarrNode`. Snowy is mounted at the same path as on calculus, so the worker is a mapped node. The mount is `nofail` (the desktop still boots when Snowy is down) and uses Snowy's LAN address, so the worker only sees the library on the home network, and only while the PC is on.

### `tintin` (macOS)

nix-darwin (`darwinConfigurations.tintin`) using `base`, `gapuchiDefaults`, Home Manager, and `homeImports` of `gapuchiTerminal` + `ghostty`. See `modules/hosts/tintin/default.nix`.

### `arjun-gt` (macOS)

Standalone Home Manager (`homeConfigurations."arjun@arjun-gt"`) using `gapuchiTerminal`, with a per-user `age.secrets` override. See `modules/hosts/arjun-gt/default.nix`.

## Add a new site behind Caddy

Caddy on `calculus` serves `*.lab.adhia.net` with a Let's Encrypt cert via Cloudflare DNS-01 (token in the `caddy-dns-token` secret). 80/443 are only reachable over Tailscale.

A name is not reachable until every item below is in the same change. Caddy alone does not create the DNS name.

1. Listen on `127.0.0.1` and an unused port. Check `modules/nixos/caddy.nix` and `modules/nixos/gatus.nix` before picking one.
2. Add `virtualHosts."<name>.lab.adhia.net"` in `modules/nixos/caddy.nix` with `reverse_proxy 127.0.0.1:<port>` and `${tls}`.
3. Add `"<name>.lab.adhia.net,${calculusHostname}"` to `cnameRecords` in `modules/nixos/pihole.nix`.
4. Add a link in `modules/nixos/homepage.nix`.
5. Add a loopback check in `modules/nixos/gatus.nix`.

qBittorrent is the exception: it runs inside the Mullvad namespace, so Caddy uses `reverse_proxy 192.168.15.1:8090`. Leave this file alone unless a service breaks that loopback pattern.
