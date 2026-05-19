# Nix / NixOS Guidelines

## Language idioms
- Prefer `let … in` to avoid deeply nested attrsets.
- Use `inherit` when binding a name to an identical name in scope.
- Use `rec` only when self-reference is genuinely required; prefer `let` otherwise.
- Use `with pkgs;` sparingly — it pollutes scope and breaks refactoring.
- Always use `lib.*` functions (`lib.mkIf`, `lib.mkOption`, `lib.optionals`, `lib.mkMerge`, etc.) — never reimplement them.

## Module structure
- Each file: one feature, one concern. No "utils" modules.
- Module signature: `{ config, lib, pkgs, ... }:` — include only what's used.
- Expose configuration via typed `lib.mkOption` with a `default` and `description`.
- Gate feature config behind `lib.mkIf config.<module>.enable { … }`.
- Never hardcode values that logically belong to options.

## Home-manager patterns
- Dotfiles that need live-editing: use `config.lib.file.mkOutOfStoreSymlink`, never `builtins.path`.
- Prefer `programs.*` and `services.*` HM options over manual `home.file` configs where HM has native support.
- New packages: `home.packages` in `packages.nix`; only create a dedicated module file if the package needs config.

## Flake conventions
- Inputs: pin with `follows` where appropriate to reduce closure size.
- `nixpkgs.config.allowUnfree` goes in `nixpkgs` module, not in flake outputs.
- Keep `flake.nix` thin — just wiring; logic lives in modules.

## Testing changes
```bash
# Quick syntax/eval check:
nix flake check

# Full system rebuild (run as root or with sudo):
sudo nixos-rebuild switch --flake ~/nixos-config#nixos

# Home-manager only (much faster):
home-manager switch --flake ~/nixos-config#phatle

# Debug eval errors:
nix eval .#nixosConfigurations.nixos.config.<option> --show-trace
```

## Common pitfalls
- Infinite recursion: accessing `config.X` inside the option definition of `config.X`.
- Option collisions: two modules set the same option without `lib.mkForce` / `lib.mkDefault`.
- IFD: `builtins.readFile` on a derivation output — use `lib.fileContents` or restructure.
- Forgetting to import a new module file in `hosts/nixos/default.nix` or `home/phatle/default.nix`.
