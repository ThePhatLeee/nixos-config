# nixos-config — Plan & Status

**Machine:** Dell XPS 15 9510 · i7-11800H · RTX 3050 Ti  
**Use cases:** Software dev · Linux/ICT/IT · Cybersecurity · Tradenomi studies  
**Last audit:** 2026-05-22

---

## Architecture

```
HOST (NixOS — hardened, minimal, clean)
│  No offensive tools. No dev runtimes. No unnecessary attack surface.
│
├── Containers (Podman rootless + distrobox — Ubuntu 24.04)
│     frontend   --nvidia  Node.js · pnpm · bun · Three.js/WebGL
│     backend              PHP/Laravel · Python · Java · .NET · Go · Rust · C++ · DBs
│     fullstack  --nvidia  frontend + backend combined
│     it                   Ansible · networking · AD/LDAP/Kerberos · PowerShell
│
├── VMs (KVM/QEMU — virt-manager)
│     Kali Linux  — ALL offensive/diagnostic security tooling
│     Windows     — IT support · AD lab · Office · RDP testing
│
└── Host-only
      Desktop · academic · creative · communication · recording
      Git · GPG/SSH agent · secrets (sops-nix)
```

---

## What Is Done

### Boot + Security
- Lanzaboote (Secure Boot deployed), latest kernel, VMD fix, tmpfs /tmp
- TPM2 auto-unlock configured (systemd initrd, crypttabExtraOpts, tpm2-tools)
- USBGuard with real allowlist (XPS built-ins, Dell DA310, SanDisk, Logitech)
- AppArmor + auditd + earlyoom + sudo hardening + coredumps off + kernel sysctls
- SSH key-only, no root login, fail2ban

### System modules (`modules/nixos/system/`)
- audio · bluetooth · boot · containers · disks · locale · networking
- security · snapshots · sops · ssh · tpm · usbguard · users · virtualization · vpn (placeholder)

### Hardware (`modules/nixos/hardware/`)
- nvidia (open Ampere, PRIME offload, powerManagement, dynamicBoost)
- performance (BBR+FQ, socket buffers, inotify, I/O schedulers, THP=madvise)
- power (TLP 20-80% charge, irqbalance, fwupd, UPower)
- blender (CUDA + cudnn, system package)
- printing

### Desktop (`modules/nixos/desktop/`)
- Hyprland + UWSM + xwayland + XDG portals + polkit + gnome-keyring
- SDDM Wayland + sddm-astronaut (Compline palette, custom wallpaper)
- Plymouth mac-style boot splash
- Steam (32-bit + proton-ge-bin + gamemode)
- Fonts (JetBrainsMono/FiraCode Nerd Fonts, Inter, Noto)

### Nix (`modules/nixos/nix/`)
- Flakes, substituters (cache.nixos.org + hyprland.cachix + nix-community), allowUnfree
- openldap i686 overlay (skips flaky checkPhase — Lutris dep)
- zramSwap, nh, nom, nvd, nix-tree, statix, deadnix, alejandra

### Secrets (sops-nix)
- GPG signing key imported: `BFC6E2CF...` (phat.le@thephatle.dev) — ultimate trust
- GPG encryption key imported: `7C4E1987...` (jokinenmarko1@gmail.com) — ultimate trust
- Age key derived from SSH host key → `/var/lib/sops-nix/key.txt`
- `.sops.yaml` fully wired: both PGP fingerprints + age public key

### Home modules
- apps: academic (Obsidian, LaTeX, Pandoc) · communication (Signal, Nordpass)
  creative (GIMP, Inkscape, Darktable, LibreOffice, Thunderbird)
  gaming (Heroic, Lutris) · media (mpv, imv, pear-desktop) · recording (OBS, DaVinci)
  sync (Syncthing) · theming (pywal + pywalfox) · vscode (vscode-fhs + gh)
- cli: git (lazygit+delta, GPG signing) · btop/dust/duf · nix-index+comma
  utils (fastfetch/ripgrep/fd/jq/claude-code/mcp-server-filesystem) · yazi/zathura
- dev: distrobox · podman-compose · podman-desktop · gnupg · age · gopass · ssh-agent
- shell: zsh · eza · fzf · direnv+nix-direnv · zellij · starship · zoxide · atuin · bat

### Hyprland dotfiles (`dotfiles/hypr/`)
- 7 persistent workspaces (hl.workspace_rule), WP2 as boot default
- Staggered autostart: VSCode→WP1 (0s) · Firefox→WP2 (2s) · Thunderbird→WP4 (4s) · Signal→WP5 (6s)
- Workspace window rules (silent assignment — no focus steal)
- Kanshi monitor profiles: laptop (eDP-1 scale 1.2) + docked (DP-3 external, eDP-1 off)

### Dotfiles symlink map
```
dotfiles/hypr/         → ~/.config/hypr/
dotfiles/kitty/        → ~/.config/kitty/
dotfiles/zellij/       → ~/.config/zellij/
dotfiles/starship/     → ~/.config/starship.toml   (Compline palette powerline)
dotfiles/noctalia/     → ~/.config/noctalia/
dotfiles/yazi/         → ~/.config/yazi/
dotfiles/zathura/      → ~/.config/zathura/
dotfiles/lazygit/      → ~/.config/lazygit/
dotfiles/btop/         → ~/.config/btop/
dotfiles/kanshi/       → ~/.config/kanshi/
dotfiles/zsh/          → extra.zsh sourced from .zshrc
dotfiles/claude/       → ~/.claude/               (skills · agents · statusline)
```

### Claude Code setup
- 19 skills in `dotfiles/claude/skills/<name>/SKILL.md` (invoked via `/<name>`)
- Obsidian MCP via `mcp-server-filesystem` (no nodejs, native nixpkgs binary)
- Statusline: Compline palette (matches starship + Noctalia Compline colorscheme)

---

## Pending

### Needs `nh os switch` to apply
Everything above is committed and pushed. Run the rebuild.

**After rebuild:**
```bash
hyprctl reload
sudo mkdir -p /home/.snapshots && sudo chown root:wheel /home/.snapshots && sudo chmod 750 /home/.snapshots
gh auth login
```

### TPM2 enrollment
```bash
sudo systemd-cryptenroll /dev/disk/by-partlabel/luks
# If no tpm2 slot:
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7+15 /dev/disk/by-partlabel/luks
```

### First sops secret
sops infrastructure is ready. Create secrets as needed:
```bash
sops secrets/example.yaml
```

### Distrobox containers + VMs
See `DISTROBOX_SETUP.md` — create all 4 containers, spin up Kali + Windows via virt-manager.

### NordVPN
Not in nixpkgs. `vpn.nix` is a placeholder. Install manually or via the `it` container.

### AppArmor custom profiles
Run Firefox/VSCode in complain mode → review `audit.log` → write enforce profiles.
Low priority, 2-week process.

---

## Deferred

- **2026-05-30**: Switch `nixpkgs` → `nixos-26.05`, `home-manager` → `release-26.05`, bump `stateVersion` to `"26.05"`
- **Kali VM**: create manually via virt-manager (intentional — not declarative)
- **nftables deeper ruleset**: low priority for desktop, current INVALID drop + NixOS firewall is sufficient
