# nixos-config

Modular NixOS configuration — Hyprland baseline.

## Structure

```
nixos-config/
│
├── flake.nix                        # Inputs: nixpkgs-unstable + home-manager
│
├── hosts/nixos/
│   ├── default.nix                  # Hostname, stateVersion, imports all modules
│   └── hardware-configuration.nix   # Machine-specific hardware — committed, but regenerate for each new machine
│
├── modules/nixos/                   # System-level NixOS modules
│   ├── boot.nix                     # systemd-boot, latest kernel, quiet boot
│   ├── networking.nix               # NetworkManager, firewall
│   ├── audio.nix                    # Pipewire + wireplumber
│   ├── bluetooth.nix                # Bluetooth + blueman
│   ├── hyprland.nix                 # programs.hyprland, xdg-portal, wayland env vars
│   ├── fonts.nix                    # Nerd Fonts, Inter, Noto, JetBrains Mono
│   ├── nix-settings.nix             # Flakes, cachix, auto-GC
│   └── users.nix                    # User + groups
│
├── home/
│   ├── phatle/default.nix           # Home-manager root: cursor, GTK, imports modules
│   └── modules/
│       ├── hypr.nix                 # HM hyprland enable + sources dotfiles/hypr/conf/
│       ├── services.nix             # hyprlock, hypridle, hyprpaper (HM-managed)
│       ├── waybar.nix               # Installs waybar, symlinks dotfiles/waybar/
│       ├── packages.nix             # User packages
│       └── apps/
│           └── kitty.nix            # Installs kitty, symlinks dotfiles/kitty/
│
└── dotfiles/                        # ← EDIT THESE — symlinked to ~/.config/
    ├── hypr/conf/                   # Hyprland config (sourced directly from repo path)
    │   ├── general.conf             # Layout, gaps, borders, $vars
    │   ├── monitors.conf            # Monitor setup
    │   ├── appearance.conf          # Rounding, blur, shadow
    │   ├── animations.conf          # Bezier + animation timings
    │   ├── input.conf               # Keyboard, touchpad, gestures
    │   ├── keybinds.conf            # All key bindings
    │   ├── windowrules.conf         # Window rules
    │   └── autostart.conf           # exec-once entries
    ├── kitty/
    │   └── kitty.conf               # Symlinked to ~/.config/kitty/
    └── waybar/
        ├── config.jsonc             # Symlinked to ~/.config/waybar/
        └── style.css
```

## How dotfiles work

| File | Where it ends up | How to apply changes |
|---|---|---|
| `dotfiles/hypr/conf/*.conf` | Sourced directly by Hyprland | `hyprctl reload` |
| `dotfiles/kitty/kitty.conf` | `~/.config/kitty/` (symlink) | Reopen kitty |
| `dotfiles/waybar/` | `~/.config/waybar/` (symlink) | `killall waybar; waybar &` |
| Nix modules | System/home config | `sudo nixos-rebuild switch --flake ~/nixos-config#nixos` |

## Fresh install from ISO

**Phase 1 — on the ISO (sets up disks + standard NixOS install):**

```bash
# Run the disk setup + install script
# It partitions, encrypts, formats BTRFS, mounts, creates swap, then runs nixos-install.
# You will be prompted for: disk choice, LUKS passphrase, root password.
sudo bash <(curl -L https://raw.githubusercontent.com/ThePhatLeee/nixos-config/main/install.sh)
```

Reboot. Log in as **root** (password you just set).

---

**Phase 2 — after first boot (switch to this flake config):**

```bash
# 1. Clone this repo
nix-shell -p git --run "git clone https://github.com/ThePhatLeee/nixos-config ~/nixos-config"

# 2. Regenerate hardware config for this machine (no filesystems — the flake owns those)
nixos-generate-config --no-filesystems
cp /etc/nixos/hardware-configuration.nix \
   ~/nixos-config/hosts/nixos/hardware-configuration.nix

# 3. (Optional) Enable hibernation
#    Get offset: btrfs inspect-internal map-swapfile -r /swap/swapfile
#    Edit ~/nixos-config/modules/nixos/disks.nix — uncomment the two lines, set the offset

# 4. Switch to flake config (SDDM + Hyprland will start immediately after)
sudo nixos-rebuild switch --flake ~/nixos-config#nixos

# 5. Set the phatle user password
passwd phatle
```

Login at SDDM: **phatle** / **nixos** → immediately run `passwd` to set a real password.

## First-time setup

```bash
# 1. Enable flakes in current /etc/nixos config
sudo sh -c 'echo "  nix.settings.experimental-features = [\"nix-command\" \"flakes\"];" >> /etc/nixos/configuration.nix'
sudo nixos-rebuild switch

# 2. Switch to flake config
cd ~/nixos-config
git init && git add .
sudo nixos-rebuild switch --flake ~/nixos-config#nixos
```

Or just run:
```bash
bash ~/nixos-config/bootstrap.sh
```

## Ongoing usage

```bash
# Rebuild after changing any .nix file
sudo nixos-rebuild switch --flake ~/nixos-config#nixos

# Test before switching (builds but doesn't activate)
sudo nixos-rebuild build --flake ~/nixos-config#nixos

# Roll back if something breaks
sudo nixos-rebuild switch --rollback
```

## Customize first

- [ ] `hosts/nixos/default.nix` — set `time.timeZone`
- [ ] `dotfiles/hypr/conf/monitors.conf` — set your monitor
- [ ] `dotfiles/hypr/conf/input.conf` — change `kb_layout` if not US
- [ ] `home/modules/services.nix` — add wallpaper path in hyprpaper section

## Key bindings

| Key | Action |
|---|---|
| `Super+Q` | Terminal (kitty) |
| `Super+R` | Launcher (wofi) |
| `Super+E` | Files (nautilus) |
| `Super+C` | Close window |
| `Super+V` | Toggle float |
| `Super+F` | Fullscreen |
| `Super+G` | Color picker |
| `Print` | Screenshot (output) |
| `Shift+Print` | Screenshot (region) |
| `Super+Print` | Screenshot (window) |
| `Super+H/L/K/J` | Focus direction |
| `Super+Shift+H/L/K/J` | Move window |
| `Super+Alt+H/L/K/J` | Resize window |
| `Super+1–0` | Switch workspace |
| `Super+Shift+1–0` | Move to workspace |
| `Super+S` | Scratchpad |
| `` Super+` `` | Clipboard history |
