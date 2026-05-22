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

```bash
# Full system rebuild (as root):
sudo nixos-rebuild switch --flake ~/nixos-config#nixos

# Home-manager only (faster, no sudo):
home-manager switch --flake ~/nixos-config#phatle

# Check eval without building:
nix flake check
```

## Stack

- Wayland compositor: Hyprland (Lua config in `dotfiles/hypr/`)
- Terminal: Kitty
- Shell bar/dock: Noctalia
- Display manager: SDDM
- Audio: Pipewire + Wireplumber
- Disk: BTRFS + LUKS2 (via Disko)

## Read before writing Nix

Load `~/.claude/skills/nix-guidelines.md` before making any changes to this repo.
