---
name: nix
description: Use for any .nix file, flake.nix, NixOS module, home-manager config, or this nixos-config repo. Auto-triggers on nix, nixos, home-manager, flake, pkgs, lib.mk, module, nh os switch, nixos-rebuild.
---

# Nix / NixOS Guidelines

## This repo's structure
```
modules/nixos/          system-level (hardware/, desktop/, system/, nix/)
home/modules/           home-manager (apps/, cli/, dev/, shell.nix, dotfiles.nix)
dotfiles/               live config files — symlinked, NOT copied into store
hosts/nixos/            entry point + hardware-configuration.nix
flake.nix               single host: nixosConfigurations.nixos
```

**Module placement rules:**
- One feature per file, one concern per file. No "utils" modules.
- Hardware-tied packages (blender with CUDA, nvidia, blender) → `modules/nixos/hardware/`
- Desktop packages → `modules/nixos/desktop/` or `home/modules/apps/`
- System packages → `modules/nixos/system/`
- User-space packages → `home/modules/apps/<category>.nix` or `home/modules/cli/`
- New subdirectory always preferred over stuffing into an existing module

**NEVER run rebuilds** — `nh os switch` needs sudo. User runs all rebuilds manually.
After config changes: `nix flake check --no-build` to verify eval, then tell the user to rebuild.

## Dotfiles pattern (live-editing)
```nix
# home/modules/dotfiles.nix
let
  link    = path: config.lib.file.mkOutOfStoreSymlink path;
  dotfiles = "${config.home.homeDirectory}/nixos-config/dotfiles";
in {
  home.file.".config/hypr".source = link "${dotfiles}/hypr";
}
```
- `mkOutOfStoreSymlink` → symlink to the actual repo path, not a store copy
- Changes to dotfiles/ take effect **immediately** — no rebuild needed
- New dotfiles entry: add to `home/modules/dotfiles.nix`, add dir to `dotfiles/`
- Never use `builtins.path` for live-editable files

## Language idioms
```nix
# prefer let…in over deeply nested attrsets
let
  port = 8080;
  host = "localhost";
in { networking.firewall.allowedTCPPorts = [ port ]; }

# inherit when name matches scope
{ pkgs, lib, ... }: { inherit pkgs lib; }

# with pkgs sparingly — only in package lists
home.packages = with pkgs; [ git curl vim ];

# lib.* functions — never reimplement
lib.mkIf config.services.foo.enable { ... }
lib.optionals stdenv.isLinux [ pkg ]
lib.mkForce value          # override with force
lib.mkDefault value        # allow override
lib.concatMapStrings sep f list
```

## Module signature
```nix
# Include only what you use
{ config, lib, pkgs, ... }:        # most common
{ lib, pkgs, ... }:                # no config access needed
{ config, lib, pkgs, inputs, ... } # when flake inputs needed (via specialArgs)
```

## Options pattern
```nix
{ lib, config, ... }:
{
  options.services.myThing = {
    enable = lib.mkEnableOption "my thing";
    port   = lib.mkOption {
      type    = lib.types.port;
      default = 8080;
      description = "Listening port";
    };
  };

  config = lib.mkIf config.services.myThing.enable {
    systemd.services.myThing = { ... };
  };
}
```

## Home-manager patterns
```nix
# Programs with HM support — prefer programs.* over manual packages
programs.git = { enable = true; userName = "phatle"; };

# Package needs config → dedicated module
# Package needs no config → home.packages in existing category module

# Systemd user services (UWSM session = graphical-session.target)
systemd.user.services.kanshi = {
  Unit    = { After = [ "graphical-session.target" ]; PartOf = [ "graphical-session.target" ]; };
  Service = { ExecStart = "${pkgs.kanshi}/bin/kanshi"; Restart = "on-failure"; };
  Install.WantedBy = [ "graphical-session.target" ];
};
```

## This machine's specifics
- **Display**: eDP-1 @ 3456×2160, scale 1.2 (Hyprland monitor config, NOT GDK_SCALE/QT_SCALE_FACTOR)
- **External**: DP-3 (LG HDR WQHD 3440×1440), scale 1.0 — managed by kanshi
- **GPU**: NVIDIA RTX 3050 Ti — open driver, managed by `modules/nixos/hardware/nvidia.nix` — do not touch
- **Secure Boot**: Lanzaboote + sbctl, `/var/lib/sbctl` PKI bundle
- **LUKS**: cryptroot, TPM2 auto-unlock via systemd initrd (PCRs 0+2+7+15)
- **Boot**: `boot.initrd.systemd.enable = true` already set (required for TPM2 + Plymouth)
- **Desktop**: Hyprland + UWSM + Noctalia shell
- **Theme**: Compline colorscheme — `dotfiles/noctalia/colorschemes/Compline/Compline.json`

## Git + flake requirement
New files in the repo must be `git add`ed before Nix can see them (flake uses git tree).
Forgetting this causes: `error: path '...' is not tracked by Git`

## Common pitfalls
- Infinite recursion: `config.X` inside the option definition of `config.X`
- Option collision: two modules set same option → use `lib.mkForce` / `lib.mkDefault`
- `GDK_SCALE` / `QT_SCALE_FACTOR` globally: **never** — breaks per-monitor scaling
- `build.initrd.systemd.enable`: already enabled, don't disable — breaks TPM2 unlock
- `nix flake check` fails on untracked files → `git add` first
- `youtube-music` renamed to `pear-desktop` in nixpkgs

## Flake conventions
```nix
# inputs: pin with follows to reduce closure
nix-index-database = {
  url = "github:nix-community/nix-index-database";
  inputs.nixpkgs.follows = "nixpkgs";  # shares nixpkgs, no duplicate
};

# outputs: keep flake.nix thin — just wiring
nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };  # pass inputs to modules
  modules = [ ./hosts/nixos/default.nix ... ];
};
```

## Quick reference
```bash
nix flake check --no-build          # eval check, no build (safe, no sudo)
nix eval .#nixosConfigurations.nixos.config.<option> --show-trace  # debug
git add <new-file>                  # required before flake can see new files
```
