# nixos-config

NixOS + home-manager flake configuration for a Hyprland/Wayland desktop (user: `phatle`).

## Repo layout

```
modules/nixos/      system-level NixOS modules (one feature per file)
home/modules/       home-manager modules (one concern per file)
home/phatle/        home-manager entry point — imports all home modules
hosts/nixos/        per-host config + hardware-configuration.nix
dotfiles/           live-editable config files (symlinked, not copied)
flake.nix           single host: nixosConfigurations.nixos
```

## Key conventions

- **System modules**: `modules/nixos/<feature>.nix`, imported via `hosts/nixos/default.nix`.
- **Home modules**: `home/modules/<concern>.nix`, imported via `home/phatle/default.nix`.
- **Dotfiles**: stored in `dotfiles/<app>/`, symlinked via `config.lib.file.mkOutOfStoreSymlink` in `home/modules/dotfiles.nix`. Edit these live — no rebuild needed.
- New user packages → `home/modules/packages.nix`. Create a dedicated module only if the package needs configuration.
- New symlinks → `home/modules/dotfiles.nix` using the existing `link` helper.

## Apply changes

NEVER run rebuilds yourself — the user runs `nh os switch` (needs sudo). After config changes, run `nix flake check --no-build` to verify eval, then tell the user to rebuild.

```bash
nh os switch          # full system + home rebuild (user runs, needs sudo)
nix flake check       # eval-only validation (you may run)
```

## Stack

- Wayland compositor: Hyprland (Lua config in `dotfiles/hypr/`)
- Terminal: Kitty
- Shell bar/dock: Noctalia
- Display manager: SDDM
- Audio: Pipewire + Wireplumber
- Disk: BTRFS + LUKS2 (via Disko)

## Read before writing Nix

Load the `/nix` skill (`~/.claude/skills/nix/SKILL.md`) before making any changes to this repo.
