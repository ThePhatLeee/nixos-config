# nixos-config

NixOS flake configuration for Dell XPS 15 9510 (i7-11800H + RTX 3050 Ti).  
Hyprland · Noctalia · Pipewire · BTRFS+LUKS2 · Podman containers · KVM/QEMU.

---

## Architecture

```
HOST — hardened, minimal, no dev runtimes
├── Containers (Podman rootless + distrobox — Ubuntu 24.04)
│     frontend   --nvidia  Node.js · pnpm · bun · TS · Three.js
│     backend              PHP · Python · Java · .NET · Go · Rust · C++ · DBs
│     fullstack  --nvidia  frontend + backend combined
│     it                   Ansible · networking tools · IT automation
├── VMs (KVM/QEMU — virt-manager)
│     Kali Linux — offensive security tooling
│     Windows    — IT support · AD · RDP testing
└── Host-only
      Academic · creative · communication · recording
      Git · GPG/SSH agent
```

---

## Repo layout

```
nixos-config/
├── flake.nix                         # inputs: nixpkgs-unstable, home-manager, nixos-hardware, noctalia
├── disko.nix                         # disk layout (install-time only)
├── install.sh                        # disko runner — see Install below
│
├── hosts/nixos/
│   ├── default.nix                   # hostname, stateVersion, imports all module groups
│   └── hardware-configuration.nix    # machine-specific — regenerate for new hardware
│
├── modules/nixos/
│   ├── system/    audio · bluetooth · boot · containers · disks · locale
│   │              networking · security · snapshots · ssh · usbguard
│   │              users · virtualization · vpn
│   │              tpm.nix            # deferred — Batch H (Secure Boot + TPM2)
│   ├── hardware/  nvidia · performance · power · printing · xps · blender
│   ├── desktop/   hyprland · sddm · fonts
│   └── nix/       settings · tools
│
├── home/
│   ├── phatle/default.nix            # HM root: GTK, cursor, XDG, imports modules
│   └── modules/
│       ├── apps/   academic · creative · files · hyprland · kitty · media
│       │           noctalia · recording · sync · vscode
│       ├── cli/    git · monitor · utils · viewers
│       ├── dev/    containers · gpg
│       ├── shell.nix                 # zsh · eza · fzf · direnv · zellij · starship
│       └── dotfiles.nix             # symlinks dotfiles/ → ~/.config/ (live edits)
│
└── dotfiles/                         # edit here — changes are instant, no rebuild
    ├── hypr/                         # Hyprland config
    ├── kitty/                        # terminal
    ├── zellij/                       # multiplexer
    ├── starship/                     # prompt
    ├── noctalia/                     # desktop shell settings
    ├── yazi/                         # file manager
    ├── zathura/                      # PDF viewer
    ├── lazygit/                      # git TUI
    ├── zsh/extra.zsh                 # aliases, shell init
    └── claude/                       # Claude Code config
```

---

## Apply changes

```bash
nh os switch          # rebuild system + home (always fetches latest inputs)
nh home switch        # home-manager only (faster, no sudo)
nix flake check       # validate without building
```

Changes inside `dotfiles/` are live immediately — no rebuild needed.

---

## Install

Boot the NixOS ISO, clone the repo, run the disko script, then install manually:

```bash
# 1. Clone (git available on the ISO)
nix-shell -p git --run "git clone https://github.com/ThePhatLeee/nixos-config /tmp/nixos-config"

# 2. Run disko — partitions, encrypts (LUKS2), formats BTRFS, mounts /mnt
#    Also creates swapfile and prints the hibernation resume offset.
sudo bash /tmp/nixos-config/install.sh

# 3. Update resume offset in modules/nixos/system/disks.nix with the printed value
#    (only needed if you want hibernation)

# 4. Install NixOS
nixos-install --flake /tmp/nixos-config#nixos --no-root-passwd

# 5. Reboot
reboot
```

---

## Post-install

After first login (LUKS passphrase → SDDM → desktop):

```bash
# Clone the repo to its permanent location
git clone https://github.com/ThePhatLeee/nixos-config ~/nixos-config

# Set your password
passwd

# Rebuild from the permanent location
nh os switch

# Import your GPG key
gpg --import private-key.asc
```

For Secure Boot + TPM2 auto-unlock — see `modules/nixos/system/tpm.nix` (Batch H).  
For distrobox containers — see `DISTROBOX_SETUP.md`.

---

## Key packages

| Layer | Tools |
|---|---|
| Shell | zsh · starship · zellij · eza · fzf · atuin · zoxide · bat |
| CLI | ripgrep · fd · jq · lazygit · delta · btop · dust · duf · yazi |
| Desktop | Hyprland · Noctalia · SDDM · Firefox · VSCode |
| Creative | GIMP · Inkscape · Darktable · Blender (CUDA) · OBS · DaVinci Resolve |
| Academic | LaTeX · Pandoc · Obsidian · Zotero · Anki |
| System | Podman · virt-manager · snapper · AppArmor · fail2ban · earlyoom |
