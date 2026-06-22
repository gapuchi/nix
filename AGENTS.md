# Agent guide

Unify machine setup with **Nix** across NixOS and macOS. Prefer small, correct changes that match existing patterns in this repo.

## Related docs

- **Cross-repo** — `coding-philosophy` rule; `scope-and-plan` / `execute-increment` skills (`workspace/ai`)
- [`hosts/AGENTS.md`](hosts/AGENTS.md) — per-machine details, hardware files, host wiring, Caddy sites
- [`.cursor/rules/`](.cursor/rules/) — scoped reminders (`architecture`, `modules`, `secrets`, `readme-sync`)

## Project overview

Personal Nix configuration for several machines. **Flakes** are the entry point (`flake.nix`, pinned by `flake.lock`); **Home Manager** owns user config, **nix-darwin** owns macOS systems, **agenix** manages secrets. `just` runs common tasks and `direnv` loads the dev shell on `cd`.

The flake is built with **flake-parts** + **import-tree**: `flake.nix` is tiny and `inputs.import-tree ./modules` auto-imports *every* `modules/**/*.nix`. There is no manual import list — adding a file under `modules/` is enough to load it.

## Two tiers

This is the boundary agents must respect. Module files do **not** produce machine config directly; they register reusable modules. Host files assemble them into outputs.

| Tier | Path | Role |
|------|------|------|
| **Module library** | `modules/{nixos,darwin,home-manager}/*.nix` | Register named modules into `config.flake.modules.{nixos,darwin,homeManager}.<name>` |
| **Host wiring** | `modules/hosts/<host>/default.nix` | Build `flake.{nixosConfigurations,darwinConfigurations,homeConfigurations}` by selecting registered modules + setting `my.*` options |
| **Flake plumbing** | `modules/{options,systems,devshell}.nix` | flake-parts setup, supported systems, dev shell |
| **Shared helpers** | `modules/_lib/*.nix` | Plain attrsets (`ssh-keys.nix`, `devices.nix`), `import`ed directly — not flake modules |

### Module kinds (in the library)

- **base** (`base.nix`) — declares `options.my.{nixos,darwin,home}` and baseline config. The contract every host fills in.
- **feature** — one concern, e.g. `caddy`, `plex`, `git`, `zsh`, `mafiaBot`. Localizes its own effects (secrets, systemd units, packages).
- **bundle** — composes features via `imports`, e.g. `gapuchiTerminal`, `gapuchiDesktop`, `gapuchiServer`, `gapuchiLinuxBase`, `gapuchiBase`.

### The `my.*` contract + `homeImports` seam

Hosts and bundles only ever set `my.*`; they never reach into a feature's internals.

- `my.nixos` — `hostName`, `authorizedKeys`, `username`, `homeDirectory`, `stateVersion`, `homeImports`
- `my.darwin` — `hostName`, `username`, `homeDirectory`, `homeImports`
- `my.home` — `username`, `homeDirectory`, `git.{name,email}`

`homeImports` is the seam from system → Home Manager: `base.nix` wires `home-manager.users.<user>.imports = cfg.homeImports`, so a host (or server/desktop bundle) selects the HM bundle by setting `my.{nixos,darwin}.homeImports = [ gapuchiTerminal ]`.

## Key patterns

- **File name vs module name**: files are **kebab-case** (`gapuchi-terminal.nix`), registered module names are **camelCase** (`gapuchiTerminal`, `mafiaBot`, `worldCupBot`, `uptimeKuma`).
- Reference other registered modules via `config.flake.modules.<class>` (commonly aliased `nixosMods` / `hmMods` / `darwinMods` in a `let`), then `imports = with nixosMods; [ … ]`.
- A feature that wraps an external flake reads its package from `inputs.<name>.packages.${pkgs.stdenv.hostPlatform.system}.default`.

## Machine categories (constraints)

When adding packages or home options, respect the target:

| Category | Platform | Notes |
|----------|----------|-------|
| **Linux desktop** | NixOS | Full desktop is OK. |
| **Linux server** | NixOS, headless | No desktop environment. **Do not** add packages whose main purpose is a GUI. |
| **Mac** | nix-darwin or standalone Home Manager | **Do not** add packages whose main purpose is a GUI. |

## Secrets (agenix)

Plaintext secrets, private keys, and credential env files must never be committed. A line in `secrets.nix` alone does nothing — Nix must reference the `.age` file. Workflow:

1. Add a rule in `secrets.nix`: `secrets/<name>.age` → `publicKeys` (SSH keys from `_lib/ssh-keys.nix` allowed to decrypt).
2. Create/edit the encrypted file from the dev shell: `agenix -e secrets/<name>.age` (verify with `agenix -d`).
3. Wire it where used: `age.secrets.<name>.file = ../../secrets/<name>.age;` and consume `config.age.secrets.<name>.path`. The agenix module must be imported for that target (`inputs.agenix.{nixosModules,homeManagerModules}.default`).

## Common tasks

| Task | Where |
|------|-------|
| Add a feature module | New `modules/<class>/<kebab>.nix` registering `flake.modules.<class>.<camel>`; add to a bundle's `imports` or a host's module list |
| Add a package for a user | `modules/home-manager/base.nix` (`home.packages`) or the relevant HM feature/bundle |
| Add a NixOS service | New `modules/nixos/<svc>.nix`; import it in `modules/hosts/<host>/default.nix` |
| Add a machine | New `modules/hosts/<host>/default.nix` (+ `hosts/<host>/hardware-configuration.nix` for NixOS); see `hosts/AGENTS.md` |
| Add a secret | `secrets.nix` + `secrets/<name>.age` + `age.secrets` reference (see above) |
| Add a site behind Caddy | `hosts/AGENTS.md` → Caddy section |

## What not to do

- Don't add a manual import list to `flake.nix` — `import-tree` already loads every `modules/**/*.nix`.
- Don't set machine config in a feature file or read `my.*` to branch behavior across hosts; features stay generic and hosts select them.
- Don't have a host reach into a feature's internals — go through `my.*` options and `homeImports`.
- Don't add GUI packages to server or macOS targets (see machine categories).
- Don't commit plaintext secrets or key material; don't add a `secrets.nix` rule without a corresponding `age.secrets` reference.

## Running checks

```bash
just switch   # apply the current configuration (s)
just update   # refresh flake.lock inputs (u)
just check    # nix flake check --all-systems (c)
just version  # show configuration revision (v)
```
