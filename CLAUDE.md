# Agent instructions

## Purpose

Unify machine setup with **Nix** across NixOS and macOS. Prefer small, correct changes that match existing patterns in this repo.

## Stack

- **Flakes** — `flake.nix` is the entry point; `flake.lock` pins inputs.
- **Home Manager** — user/home config lives under `home/`.
- **direnv** — loads dev shells from `flake.nix` `devShells` when you enter the repo.
- **Just** — common tasks live in `.justfile` (see Commands).

## Machine categories (constraints)

When adding packages or home options, respect the target:

| Category | Platform | Notes |
|----------|----------|--------|
| **Linux desktop** | NixOS | Full desktop is OK. |
| **Linux server** | NixOS, headless | No desktop environment. **Do not** add packages whose main purpose is a GUI. |
| **Mac** | Standalone Nix | **Do not** add packages whose main purpose is a GUI. |

## Commands

| Command | Use |
|---------|-----|
| `just switch` | Apply the current configuration. |
| `just update` | Refresh `flake.lock` (update flake inputs). |

## Guidelines (priority order)

1. Follow Nix and Home Manager best practices.
2. Unify configuration and reduce duplication across machines when it stays clear.

## Secrets

Secrets are managed with **agenix**. Do not commit plaintext secrets, private keys, generated key material, or ad-hoc env files containing credentials.

**Workflow for a new or changed secret**

1. Add a rule in `secrets.nix` (path under `secrets/*.age` and `publicKeys` — SSH public keys allowed to decrypt).
2. Create or edit the encrypted file in `secrets/` (e.g. with `agenix` from this repo’s dev shell).
3. Wire it in Nix where it is used: `age.secrets.<name>.file = …` pointing at the `.age` file. A line in `secrets.nix` alone does nothing until Nix references the file — search for `age.secrets` and `secrets/` in `hosts/` to match existing patterns (e.g. `hosts/modules/`).

| Command | Use |
|---------|-----|
| `agenix -e <path>` | Create or edit an encrypted secret (path under `secrets/…`). |
| `agenix -d <path>` | Decrypt to stdout (verify contents). |
