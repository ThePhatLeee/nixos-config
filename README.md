# nixos-config

NixOS flake configuration for Dell XPS 15 9510 (i7-11800H + RTX 3050 Ti).  
Hyprland · Noctalia · Pipewire · BTRFS+LUKS2 · Podman containers · KVM/QEMU.

---

## Architecture

```
HOST (NixOS — hardened, minimal, no dev runtimes)
│
├── Containers (Podman rootless + distrobox — Ubuntu 24.04)
│     frontend   --nvidia  Node.js · pnpm · bun · Three.js/WebGL
│     backend              PHP/Laravel · Python · Java · .NET · Go · Rust · C++ · DBs
│     fullstack  --nvidia  frontend + backend combined
│     it                   Ansible · network tools · AD/LDAP · PowerShell · automation
│
├── VMs (KVM/QEMU — virt-manager)
│     Kali Linux  — all offensive security tooling
│     Windows     — AD lab · RDP testing · Office · Windows-only tools
│
└── Host-only
      Desktop · academic · creative · communication · recording
      Git · GPG/SSH agent · secrets (sops-nix)
```

---

## Repo layout

```
nixos-config/
├── flake.nix                         # inputs: nixpkgs-unstable, home-manager, sops-nix, noctalia
├── disko.nix                         # disk layout: BTRFS+LUKS2 (install-time only)
├── install.sh                        # disko runner
│
├── hosts/nixos/
│   ├── default.nix                   # hostname, stateVersion, imports all module groups
│   └── hardware-configuration.nix
│
├── modules/nixos/
│   ├── system/    audio · bluetooth · boot · containers · disks · locale
│   │              networking · security · snapshots · sops · ssh · tpm
│   │              usbguard · users · virtualization · vpn
│   ├── hardware/  nvidia · performance · power · printing · xps · blender
│   ├── desktop/   hyprland · sddm · fonts · gaming · plymouth
│   └── nix/       settings · tools
│
├── home/
│   ├── phatle/default.nix
│   └── modules/
│       ├── apps/   academic · communication · creative · files · gaming
│       │           hyprland · media · noctalia · recording · sync · theming · vscode
│       ├── cli/    git · monitor · nix-index · utils · viewers
│       ├── dev/    containers · gpg
│       ├── shell.nix                 # zsh · eza · fzf · direnv · zellij · starship
│       └── dotfiles.nix             # symlinks dotfiles/ → ~/.config/ (live edits)
│
├── dotfiles/                         # edit here — changes are instant, no rebuild
│   ├── hypr/          Hyprland + hypridle + hyprpaper (Lua config)
│   ├── noctalia/      shell settings · Compline colorscheme · plugins
│   ├── kitty/         terminal
│   ├── zellij/        multiplexer
│   ├── starship/      prompt
│   ├── yazi/          file manager
│   ├── zathura/       PDF viewer
│   ├── lazygit/       git TUI
│   ├── btop/          system monitor
│   ├── kanshi/        monitor profiles (laptop / docked)
│   ├── zsh/           extra.zsh — aliases, shell init
│   └── claude/        Claude Code config · skills · agents
│
├── secrets/                          # sops-nix encrypted secrets (*.yaml)
├── DISTROBOX_SETUP.md               # container + VM one-liners
├── VSCODE_EXTENSIONS.md
└── PLAN.md                          # architecture decisions + roadmap
```

---

## Apply changes

```bash
nh os switch          # full system + home rebuild (needs sudo internally)
nh home switch        # home-manager only, faster, no sudo
nix flake check       # eval-only validation, no build
```

Changes inside `dotfiles/` are live immediately — `hyprctl reload` for Hyprland, no rebuild needed for anything else.

---

## Install

Boot the NixOS ISO, clone the repo, run disko, install:

```bash
# 1. Clone
nix-shell -p git --run "git clone https://github.com/ThePhatLeee/nixos-config /tmp/nixos-config"

# 2. Partition, encrypt (LUKS2), format BTRFS, mount /mnt
#    Prints the hibernation resume offset — note it for step 3.
sudo bash /tmp/nixos-config/install.sh

# 3. Set the hibernation resume offset (if you want hibernation)
#    Edit modules/nixos/system/disks.nix → kernelParams → resume_offset=<value>

# 4. Install
nixos-install --flake /tmp/nixos-config#nixos --no-root-passwd

# 5. Reboot
reboot
```

---

## Post-install

After first login (LUKS passphrase → SDDM → desktop):

### 1. Clone repo and set password

```bash
git clone git@github.com:ThePhatLeee/nixos-config ~/nixos-config
passwd
```

### 2. Import GPG keys

```bash
# Import signing key (development identity: phat.le@thephatle.dev)
gpg --import signing-key.asc
echo "BFC6E2CF1A75CF948DB7976109D801B2351193B1:6:" | gpg --import-ownertrust

# Import encryption key (secrets: jokinenmarko1@gmail.com)
gpg --import encryption-key.asc
echo "7C4E19872E2BFC518DBD1F4FE4F558182A1278F2:6:" | gpg --import-ownertrust
```

### 3. Set up SSH keys

```bash
cp /path/to/keys/id_* ~/.ssh/
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub
ssh-keyscan github.com gitlab.com codeberg.org >> ~/.ssh/known_hosts

# Test
ssh -T git@github.com
```

### 4. Rebuild

```bash
cd ~/nixos-config
nh os switch
```

### 5. Post-rebuild (one-time, order matters)

```bash
# Hyprland — reload live config
hyprctl reload

# sops-nix — derive age key from SSH host key
sudo mkdir -p /var/lib/sops-nix
sudo sh -c "nix run nixpkgs#ssh-to-age -- -private-key -i /etc/ssh/ssh_host_ed25519_key | tee /var/lib/sops-nix/key.txt"
sudo chmod 600 /var/lib/sops-nix/key.txt

# Get the age public key and paste it into .sops.yaml
nix shell nixpkgs#age -c age-keygen -y /var/lib/sops-nix/key.txt
# → copy the age1... output
# → edit .sops.yaml: replace REPLACE_WITH_AGE_PUBLIC_KEY_AFTER_REBUILD

# GitHub CLI auth
gh auth login

# Snapper home target dir
sudo mkdir -p /home/.snapshots
sudo chown root:wheel /home/.snapshots
sudo chmod 750 /home/.snapshots
```

### 6. TPM2 enrollment (optional — auto-unlock LUKS on boot)

```bash
# Check current slots
sudo systemd-cryptenroll /dev/disk/by-partlabel/luks

# Enroll if no tpm2 slot
sudo systemd-cryptenroll \
  --tpm2-device=auto \
  --tpm2-pcrs=0+2+7+15 \
  /dev/disk/by-partlabel/luks
```

### 7. Distrobox containers

See `DISTROBOX_SETUP.md` — create `frontend`, `backend`, `fullstack`, `it` containers and spin up Kali/Windows VMs via virt-manager.

---

## Key packages

| Layer | Tools |
|---|---|
| Shell | zsh · starship · zellij · eza · fzf · atuin · zoxide · bat |
| CLI | ripgrep · fd · jq · lazygit · delta · btop · dust · duf · yazi |
| Desktop | Hyprland · Noctalia · SDDM (Compline) · Firefox · VSCode |
| Creative | GIMP · Inkscape · Darktable · Blender (CUDA) · OBS · DaVinci Resolve |
| Academic | LaTeX · Pandoc · Obsidian (MCP → Claude Code) |
| Gaming | Steam (Proton GE) · Heroic · Lutris |
| System | Podman · distrobox · virt-manager · snapper · AppArmor · sops-nix |

---

## Secrets (sops-nix)

Secrets live in `secrets/*.yaml`, encrypted to two PGP keys + one age key.  
After rebuild, derive the age key (step 5 above). To create a new secret:

```bash
sops secrets/example.yaml
```

The age key (`/var/lib/sops-nix/key.txt`) is derived from the SSH host key and regenerated automatically after re-installing.

---

## Pending

- **NordVPN** — not in nixpkgs, `vpn.nix` is a placeholder. Install manually or via distrobox.
- **May 30, 2026** — switch `nixpkgs` → `nixos-26.05`, `home-manager` → `release-26.05`, bump `stateVersion` to `"26.05"`.
- **AppArmor custom profiles** — run Firefox/VSCode in complain mode, review `audit.log`, write enforce profiles.
