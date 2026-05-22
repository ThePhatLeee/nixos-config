# nixos-config — S+++ Tier Roadmap

**Machine:** Dell XPS 15 9510 · i7-11800H · RTX 3050 Ti · Daily driver  
**Use cases:** Software dev · Linux/ICT/IT support · Cybersecurity studies · Tradenomi studies  
**Last audit:** 2026-05-22

---

## Architecture

```
HOST (NixOS — hardened, minimal, clean)
│  No offensive tools. No dev runtimes. No unnecessary attack surface.
│
├── Containers (Podman rootless + distrobox — Ubuntu 24.04)
│     frontend   --nvidia  Node.js · pnpm · bun · TS · Three.js/WebGL
│     backend              PHP/Laravel · Python · Java · .NET · Go · Rust · C++ · DBs
│     fullstack  --nvidia  frontend + backend combined (for full-stack projects)
│     it                   Ansible · networking tools · IT automation
│
├── VMs (KVM/QEMU — virt-manager)
│     Kali Linux  — ALL offensive + diagnostic security tooling
│     Windows     — IT support · Active Directory · Office · RDP testing
│
└── Host-only
      Academic · creative · communication · recording
      Git · GPG/SSH agent (system auth)
      System daemons only (no dev runtimes)
```

---

## Current State — What Is Done

### Boot + Security (fully hardened)
- `boot.nix` — Lanzaboote (Secure Boot: enabled/deployed), latest kernel, VMD fix, silent boot, tmpfs /tmp 4G
- `tpm.nix` — TPM2 auto-unlock configured (initrd systemd, crypttabExtraOpts, tpm2-tools)
- `usbguard.nix` — USBGuard enabled with real allowlist (XPS built-ins, Dell DA310 dock, SanDisk, Logitech webcam)
- `security.nix` — AppArmor, auditd (fixed: auid form, no read-only ops), earlyoom, sudo hardening, coredumps off, full kernel hardening sysctls, PAM limits
- `ssh.nix` — key-only, no root, grace=30s, fail2ban

### System modules (`modules/nixos/system/`)
- `audio.nix` — Pipewire + Wireplumber + rtkit
- `bluetooth.nix` — BlueZ
- `containers.nix` — rootless Podman, Docker compat, DNS, autoPrune weekly
- `disks.nix` — BTRFS + LUKS2 (Disko), swapfile, hibernation resume
- `locale.nix` — timezone, language
- `networking.nix` — NM + systemd-resolved (DoT), WiFi MAC randomization, nftables + INVALID drop + ICMP rate limit + connection logging
- `snapshots.nix` — snapper (root+home), BTRFS monthly scrub + balance
- `users.nix` — phatle user, wheel/libvirtd/kvm/gamemode groups
- `virtualization.nix` — libvirtd, swtpm, SPICE, virt-manager
- `vpn.nix` — placeholder (NordVPN not in nixpkgs)

### Hardware modules (`modules/nixos/hardware/`)
- `blender.nix` — blender with CUDA + cudnn
- `nvidia.nix` — open driver, powerManagement, dynamicBoost
- `performance.nix` — BBR+FQ, socket buffers, inotify, vm tuning, I/O schedulers, THP=madvise, etc.
- `power.nix` — TLP (20-80% charge), irqbalance, fwupd, UPower

### Desktop (`modules/nixos/desktop/`)
- `fonts.nix` — JetBrainsMono/FiraCode Nerd Fonts, Inter, Noto
- `gaming.nix` — Steam (with 32-bit libs + remote play), gamemode
- `hyprland.nix` — Hyprland + UWSM + xwayland, XDG portals, polkit, dconf, gnome-keyring, Wayland env vars
- `sddm.nix` — SDDM Wayland + sddm-astronaut theme (Tokyo Night palette, custom wallpaper bundled)

### Nix (`modules/nixos/nix/`)
- `settings.nix` — flakes, substituters, allowUnfree, zramSwap, builders-use-substitutes
- `tools.nix` — nh, nom, nvd, nix-tree, statix, deadnix, alejandra, manix, nurl, nix-init

### Home modules
- `apps/academic.nix` — Obsidian, Zotero, Anki, LaTeX, Pandoc, Xournal++
- `apps/communication.nix` — Signal, Nordpass
- `apps/creative.nix` — GIMP, Inkscape, Darktable, LibreOffice, Thunderbird
- `apps/files.nix` — Nautilus, file-roller
- `apps/gaming.nix` — Heroic, Lutris, Wine, Winetricks, Mangohud
- `apps/hyprland.nix` — hyprcursor/idle/polkit/picker/shot, kanshi (+ systemd user service)
- `apps/kitty.nix`
- `apps/media.nix` — mpv, imv, pear-desktop (YouTube Music)
- `apps/noctalia.nix`
- `apps/recording.nix` — OBS+plugins, DaVinci
- `apps/sync.nix` — Syncthing
- `apps/theming.nix` — pywal + pywalfox
- `apps/vscode.nix` — vscode-fhs + gh
- `cli/` — git (lazygit+delta), btop/dust/duf, nix-index+comma, utils (fastfetch/ripgrep/fd/jq/claude-code/etc.), viewers (yazi/zathura)
- `dev/` — containers (distrobox, podman-compose, podman-desktop), gpg (gnupg, age, gopass, gpg-agent+SSH, pinentry-gnome3)
- `shell.nix` — zsh, eza, fzf, direnv+nix-direnv, zellij, starship, zoxide, atuin, bat

### Dotfiles — live symlink map
```
dotfiles/hypr/         → ~/.config/hypr/
dotfiles/kitty/        → ~/.config/kitty/
dotfiles/zellij/       → ~/.config/zellij/
dotfiles/starship/     → ~/.config/starship.toml
dotfiles/noctalia/     → ~/.config/noctalia/      (settings + colorschemes/Compline/Compline.json)
dotfiles/yazi/         → ~/.config/yazi/
dotfiles/zathura/      → ~/.config/zathura/
dotfiles/lazygit/      → ~/.config/lazygit/
dotfiles/btop/         → ~/.config/btop/          (noctalia theme)
dotfiles/kanshi/       → ~/.config/kanshi/         (docked + laptop profiles)
dotfiles/claude/       → ~/.claude/
```

### Monitors (kanshi profiles — active after rebuild)
- **laptop** (undocked): eDP-1 @ 3456×2160@60 scale 1.2
- **docked**: eDP-1 disabled, DP-3 (LG HDR WQHD) @ 3440×1440@60 scale 1.0 at 0,0

### Flake inputs
- nixpkgs (unstable → switch to 26.05 on 2026-05-30)
- home-manager, noctalia, nixos-hardware, nix-index-database, lanzaboote

---

## Pending — Rebuild Ready (everything in one `nh os switch`)

All config is written and `nix flake check` passes. Staged in git.

**System changes:**
- `audit-rules-nixos.service` fix (auid form, no read-only kernel ops)
- gaming.nix: Steam + gamemode
- sddm.nix: astronaut theme with Tokyo Night + wallpaper
- networking.nix: INVALID conntrack drop + connection logging
- hyprland.nix: removed wrong GDK_SCALE/QT_SCALE_FACTOR globals

**Home changes:**
- apps/communication.nix: Signal + Nordpass
- apps/gaming.nix: Heroic + Lutris + Wine + Mangohud
- apps/media.nix: pear-desktop (YouTube Music)
- apps/hyprland.nix: kanshi package + systemd user service
- dotfiles.nix: btop + kanshi symlinks
- Kanshi profiles live in dotfiles/kanshi/config

**After rebuild:**
- Run `hyprctl reload` — kanshi applies immediately for monitor switching
- Run `pkill noctalia-shell` — Compline colorscheme appears
- Restart session once to activate kanshi systemd service

---

## Gaps — What Is Still Missing

### One-off commands (no rebuild)

**`/home/.snapshots` missing:**
```bash
sudo mkdir -p /home/.snapshots && sudo chown root:wheel /home/.snapshots && sudo chmod 750 /home/.snapshots
```

**TPM2 enrollment — check if enrolled:**
```bash
sudo systemd-cryptenroll /dev/disk/by-partlabel/luks
# If no tpm2 slot: sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7+15 /dev/disk/by-partlabel/luks
```

**SSH/GPG keys — kaamos.dots not imported:**
- Extract `kaamos.dots-main.zip` from `~/Downloads/`
- `gpg --import` private + public key, set trust
- `cp` SSH key to `~/.ssh/`, chmod 600
- Test: `ssh -T git@github.com`

**`initialPassword = "nixos"` in Nix store** — cleartext but harmless (passwd overrides it). Clean up when setting up sops-nix.

### Deferred (needs planning or prerequisites)

**Obsidian MCP** — wire Claude Code to Obsidian vault via MCP server  
- Install Obsidian Local REST API plugin, pick MCP server, add to `dotfiles/claude/settings.json`

**nftables — deeper ruleset** (low priority for desktop)
- Port-specific inbound allows, per-connection rate limiting
- Currently: INVALID drop + ICMP rate limit + NixOS firewall (sufficient for desktop)

**AppArmor custom profiles** — 2-week complain mode process
- Enable complain for Firefox + VSCode, review audit.log, write enforce profiles

**sops-nix** — deferred until age key established  
- Age key not found on system; prerequisite for secrets management

**NordVPN** — not in nixpkgs, vpn.nix is a placeholder

**Claude skills — full rewrite** (no rebuild, live via dotfiles symlink)  
See Step 8 below.

---

## Step 8 — Claude Skills Architecture

### Why rewrite

Current skills are 40-50 line stubs with no structure. Target: Freek-style skills —
`skills/<name>/SKILL.md` with frontmatter that enables `/name` slash command invocation,
domain-deep content, and `references/` subdirs for lookup tables and patterns.

### Setup context

- **Primary tool**: Claude Code CLI in Kitty/Zellij terminal (better than Claude Desktop)
- **VSCode**: Claude extension for side-panel access when coding
- **Dotfiles**: `dotfiles/claude/` → `~/.claude/` (live, no rebuild)
- **All changes take effect immediately** — just save the file

### Structural change

Before: `~/.claude/skills/nix-guidelines.md` (flat file, manually referenced)  
After: `~/.claude/skills/nix/SKILL.md` (slash command: `/nix`, auto-triggered by context)

CLAUDE.md skills section → remove manual "load at start of session" instruction,
replace with "skills auto-trigger via frontmatter description and `/name` invocation."

### Skills to write

#### Core workflow (adapt from Freek, adjusted for this stack)

| Skill | Trigger | Purpose |
|---|---|---|
| `/spec` | "plan this", "write a spec", "brainstorm" | Iterative Q&A → SPEC.md + ARCHITECTURE.md + PROMPT_PLAN.md |
| `/fix-issue` | "fix issue #N", GitHub issue URL | Branch → implement → test → PR via `gh` |
| `/review-pr` | "review PR #N", PR URL | Review diff → check CI → merge → tag release |

#### Domain skills (S++ tier, written for this exact stack)

| Skill | Trigger | What makes it specific to you |
|---|---|---|
| `/nix` | Any `.nix` file, `home-manager`, `flake`, NixOS module | Module structure rules, mkOutOfStoreSymlink pattern, UWSM, Lanzaboote, hardware specifics |
| `/frontend` | `.tsx`/`.jsx`, React, Tailwind, TypeScript | Performance-first React, Tailwind v4, TypeScript strict, no generic patterns |
| `/threejs` | Three.js, WebGL, GLSL, canvas, shader | Scene architecture, custom shaders, GLSL patterns, GPU performance, Awwwards-level effects |
| `/design` | "design this", UI work, component aesthetics | Awwwards thinking, typography obsession, motion design, no generic AI-slop aesthetics |
| `/laravel` | Laravel, PHP, Eloquent, Artisan | Full Laravel 12 conventions, Pest testing, Horizon/Octane, API design |
| `/security` | CTF, pentest, security audit, exploit, CVE | Methodology (recon→exploit→report), tool reference, OWASP, defensive host hardening |
| `/sysadmin` | Server, SSH, networking, Docker, systemd, infra | Linux sysadmin patterns, NixOS server config, networking (iptables/nftables), monitoring |

#### Per-skill reference content to include

**`/threejs`** — the most important new skill:
- Scene/camera/renderer setup patterns
- Custom `ShaderMaterial` + `RawShaderMaterial` GLSL snippets
- Performance: instancing, LOD, frustum culling, GPU readback
- Post-processing (pmndrs/postprocessing): bloom, DOF, motion blur
- React Three Fiber: `@react-three/fiber`, `@react-three/drei` patterns
- Scroll-driven animations (GSAP ScrollTrigger + R3F)
- Common Awwwards effects: particle systems, fluid sim, morph targets, env maps
- WebGPU/WebGL2 feature detection

**`/security`**:
- CTF: web (OWASP), binary (pwn), crypto, forensics, reverse engineering
- Reconnaissance: nmap, masscan, amass, subfinder
- Web: Burp Suite, SQLmap, XSS payloads, SSRF chains
- Host hardening cross-references (AppArmor, audit, USBGuard — already done on host)
- Responsible disclosure template

**`/sysadmin`**:
- NixOS server module patterns (differs from desktop)
- SSH hardening, fail2ban, key management
- Systemd service writing, journalctl analysis
- Network: VLANs, firewall rules, DNS config
- Container orchestration: Podman/Docker Compose, networking
- Monitoring: btop, Grafana stack, alert setup
- Backup strategies: BTRFS snapshots, rsync, offsite

### Files to create/modify

```
dotfiles/claude/
├── CLAUDE.md                        ← UPDATE: skills section
├── settings.json                    ← UPDATE: add mcpServers when ready
├── agents/                          ← KEEP: already good
│   ├── frontend-builder.md
│   ├── fullstack-debugger.md
│   └── ...
└── skills/
    ├── nix-guidelines.md            ← DELETE after migration
    ├── frontend-guidelines.md       ← DELETE after migration
    ├── laravel-php-guidelines.md    ← DELETE after migration
    ├── design-guidelines.md         ← DELETE after migration
    ├── nix/
    │   ├── SKILL.md                 ← WRITE (migrate + expand nix-guidelines.md)
    │   └── references/
    │       ├── module-patterns.md
    │       └── home-manager.md
    ├── frontend/
    │   ├── SKILL.md                 ← WRITE (migrate + expand frontend-guidelines.md)
    │   └── references/
    │       ├── react-patterns.md
    │       └── tailwind.md
    ├── threejs/
    │   ├── SKILL.md                 ← WRITE (new)
    │   └── references/
    │       ├── shaders.md
    │       ├── performance.md
    │       └── effects-cookbook.md
    ├── design/
    │   ├── SKILL.md                 ← WRITE (migrate + expand design-guidelines.md)
    │   └── references/
    │       └── awwwards-patterns.md
    ├── laravel/
    │   ├── SKILL.md                 ← WRITE (migrate + expand laravel-php-guidelines.md)
    │   └── references/
    │       ├── conventions.md
    │       └── testing.md
    ├── security/
    │   ├── SKILL.md                 ← WRITE (new)
    │   └── references/
    │       ├── ctf-methodology.md
    │       ├── web-attacks.md
    │       └── tools.md
    ├── sysadmin/
    │   ├── SKILL.md                 ← WRITE (new)
    │   └── references/
    │       ├── nixos-server.md
    │       └── networking.md
    ├── spec/
    │   ├── SKILL.md                 ← WRITE (adapt from Freek)
    │   └── references/
    │       └── templates.md
    ├── fix-issue/
    │   └── SKILL.md                 ← WRITE (adapt from Freek)
    └── review-pr/
        └── SKILL.md                 ← WRITE (adapt from Freek)
```

### Order to write

1. `/nix` first — used every session in this repo
2. `/threejs` — highest value, most unique, nothing like it exists in standard setups
3. `/design` — pairs with threejs for Awwwards work
4. `/frontend` — daily use
5. `/security` + `/sysadmin` — study + work
6. `/laravel` — project work
7. `/spec` + `/fix-issue` + `/review-pr` — workflow utilities

---

## Deferred Decisions

- **May 30th**: Switch `nixpkgs.url` to `github:NixOS/nixpkgs/nixos-26.05` + `home-manager/release-26.05`, update `stateVersion` to `"26.05"`
- **Kali VM** — manually created via virt-manager (intentional, not declarative)
- **Looking Glass** — skip permanently, incompatible with Optimus/PRIME
