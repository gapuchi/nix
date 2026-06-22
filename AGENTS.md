# Agent guide

Unify machine setup with **Nix** across NixOS and macOS. Prefer small, correct changes that match existing patterns in this repo.

## Related docs

- [`hosts/AGENTS.md`](hosts/AGENTS.md) — per-machine constraints, hardware files, host wiring, Caddy sites
- [`.cursor/rules/`](.cursor/rules/) — scoped reminders (`architecture`, `modules`, `secrets`, `readme-sync`)

## Project overview

Personal Nix configuration for several machines. **Flakes** are the entry point (`flake.nix`, pinned by `flake.lock`); **Home Manager** owns user config, **nix-darwin** owns macOS systems, **agenix** manages secrets. Encrypted secrets and evaluation-time private values live in the private flake [`gapuchi/nix-private`](https://github.com/gapuchi/nix-private) (`inputs.nix-private`). `just` runs common tasks and `direnv` loads the dev shell on `cd`.

The flake is built with **flake-parts** + **import-tree**: `flake.nix` is tiny and `inputs.import-tree ./modules` auto-imports `modules/**/*.nix` (directories named with a leading `_` are skipped). There is no manual import list — adding a file under `modules/` is enough to load it.

Fetching `nix-private` needs a GitHub token with read access to that repo (`access-tokens = github.com=<PAT>` in `nix.conf`, or `NIX_CONFIG`).

## Two tiers

This is the boundary agents must respect. Module files do **not** produce machine config directly; they register reusable modules. Host files assemble them into outputs.

| Tier | Path | Role |
|------|------|------|
| **Module library** | `modules/{nixos,darwin,home-manager}/` | Register named modules into `config.flake.modules.{nixos,darwin,homeManager}.<name>` |
| **Host wiring** | `modules/hosts/<host>/default.nix` | Build `flake.{nixosConfigurations,darwinConfigurations,homeConfigurations}` by selecting registered modules + setting `my.*` options |
| **Flake plumbing** | `modules/{options,systems,devshell}.nix` | flake-parts setup, supported systems, dev shell |
| **Private flake** | `inputs.nix-private` ([gapuchi/nix-private](https://github.com/gapuchi/nix-private)) | Encrypted `.age` files plus evaluation-time `identity`, `sshKeys`, `devices`, `lab` |

Within each class directory:

| Path | Role |
|------|------|
| `base.nix` | Declares `options.my.*` and baseline config — the contract every host fills in |
| `*.nix` (top level) | **Features** — one concern each (a service, program, or package set) |
| `bundles/*.nix` | **Bundles** — role presets: HM ones mostly `imports` of features; NixOS ones are machine-category baselines (boot, DE, nix settings, `homeImports`, …) plus any needed `imports` |

**Features** may be reusable (`git`, `tailscale`, `plex`) or single-host (`caddy`, `homepage`, `pihole`, `homeAssistant`, `serviceHealth`, `gatus` for calculus). Prefer portable settings when reuse is likely; hardcoding lab/host facts is fine when only that host selects the module — do not invent `my.*` knobs or a mega-bundle until a second consumer appears. Don't branch on host identity inside a feature; selection stays in host wiring.

### The `my.*` contract + `homeImports` seam

Hosts and bundles only ever set `my.*`; they never reach into a feature's internals.

- `my.nixos` — `hostName`, `authorizedKeys`, `username`, `homeDirectory`, `stateVersion`, `homeImports`
- `my.darwin` — `hostName`, `username`, `homeDirectory`, `homeImports`
- `my.home` — `username`, `homeDirectory`, `git.{name,email}`

`homeImports` is the seam from system → Home Manager: `base.nix` wires `home-manager.users.<user>.imports = cfg.homeImports`, so a host (or server/desktop bundle) selects the HM bundle by setting `my.{nixos,darwin}.homeImports = [ gapuchiTerminal ]`.

## Key patterns

- **File name vs module name**: files are **kebab-case** (`gapuchi-terminal.nix`), registered module names are **camelCase** (`gapuchiTerminal`, `mafiaBot`, `leagueBot`).
- Reference other registered modules via `config.flake.modules.<class>` (commonly aliased `nixosMods` / `hmMods` / `darwinMods` in a `let`), then `imports = with nixosMods; [ … ]`.
- A feature that wraps an external flake reads its package from `inputs.<name>.packages.${pkgs.stdenv.hostPlatform.system}.default`.

## Machine categories (constraints)

When adding packages or home options, respect the target:

| Category | Platform | Notes |
|----------|----------|-------|
| **Linux desktop** | NixOS | Full desktop is OK. |
| **Linux server** | NixOS, headless | No desktop environment. **Do not** add packages whose main purpose is a GUI. |
| **Mac** | nix-darwin or standalone Home Manager | **Do not** add packages whose main purpose is a GUI. |

## Secrets and private values (`nix-private`)

Encrypted secrets and evaluation-time private values live in [gapuchi/nix-private](https://github.com/gapuchi/nix-private) — not in this public repo. Plaintext secrets, private keys, and credential env files must never be committed anywhere.

| Kind | How public nix reads it |
|------|-------------------------|
| Encrypted `.age` | `age.secrets.<name>.file = "${inputs.nix-private}/secrets/<name>.age";` then `config.age.secrets.<name>.path` |
| Identity / git | `inputs.nix-private.identity` |
| SSH authorized keys | `inputs.nix-private.sshKeys` |
| LAN topology | `inputs.nix-private.devices` |
| Lab domain / DHCP | `inputs.nix-private.lab` |

Edit secrets **in the nix-private checkout** (agenix is in this repo's dev shell):

1. Add a rule in nix-private `secrets.nix`: `secrets/<name>.age` → `publicKeys` (keys from nix-private `ssh-keys.nix`).
2. `agenix -e secrets/<name>.age` (verify with `agenix -d`).
3. Wire the path in this repo as above; import `inputs.agenix.{nixosModules,homeManagerModules}.default` on the target.
4. Commit/push nix-private, then from this repo: `nix flake update nix-private`.

## Common tasks

| Task | Where |
|------|-------|
| Add a feature module | New `modules/<class>/<kebab>.nix` registering `flake.modules.<class>.<camel>`; add to a bundle's `imports` or a host's module list |
| Add a bundle | New `modules/<class>/bundles/<kebab>.nix` — HM: compose features; NixOS: role baseline (+ `homeImports` / `imports` as needed) |
| Add a package for a user | `modules/home-manager/base.nix` (`home.packages`) or the relevant HM feature/bundle |
| Add a NixOS service | New `modules/nixos/<svc>.nix`; import it in `modules/hosts/<host>/default.nix` |
| Add a machine | New `modules/hosts/<host>/default.nix` (+ `hosts/<host>/hardware-configuration.nix` for NixOS); see `hosts/AGENTS.md` |
| Add a secret or private value | nix-private (see above), then `age.secrets` / attr reference here + `nix flake update nix-private` |
| Add a site behind Caddy | `hosts/AGENTS.md` → Caddy section |

## What not to do

- Don't add a manual import list to `flake.nix` — `import-tree` already loads every `modules/**/*.nix` (except `/_` paths).
- Don't read `my.*` to branch behavior across hosts; hosts select modules. Single-host features may hardcode lab facts; don't pretend they're portable when they aren't.
- Don't have a host reach into a feature's internals — go through `my.*` options and `homeImports`.
- Don't add GUI packages to server or macOS targets (see machine categories).
- Don't commit plaintext secrets, key material, or put `.age` files / identity / lab topology back in this public repo.
- Don't restate module settings in `AGENTS.md` or `hosts/AGENTS.md`. A host note is for a constraint the code does not make obvious (qBittorrent is inside the Mullvad namespace, so Caddy cannot use localhost; the Tdarr worker only runs while haddock is on the home LAN). Ports, paths, umasks, queue limits, and a list of every service belong in the Nix.

## Running checks

```bash
just switch   # apply the current configuration (s)
just update   # refresh flake.lock inputs (u)
just check    # nix flake check --all-systems (c)
just version  # show configuration revision (v)
```
