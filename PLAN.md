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
dotfiles/easyeffects/  → ~/.config/easyeffects/    (presets + autoload)
dotfiles/vscode/       → ~/.vscode/argv.json        (password-store: gnome-libsecret)
dotfiles/zsh/          → extra.zsh sourced from .zshrc
dotfiles/claude/       → ~/.claude/               (skills · agents · statusline)
```

### Audio (`dotfiles/easyeffects/`)
- `services.easyeffects.enable = true` — always-on systemd user service
- Output presets: `XPS Internal`, `Z407`, `Pixel Buds Pro` in `output/`
- Autoload wiring in `autoload/output/` — device node → preset mapping for all 3 devices
- Per-device chains: XPS (EQ+bass enhancer+loudness+limiter), BT (EQ+compressor+limiter)

### SDDM (`modules/nixos/desktop/sddm.nix` + `dotfiles/sddm/`)
- Theme from `dotfiles/sddm/` via `stdenvNoCC.mkDerivation` (SDDM runs as root — must be in store)
- `extraPackages`: kdePackages.qtsvg + qtmultimedia + qtvirtualkeyboard (required by Qt6 theme)
- Fonts packaged separately via `stdenvNoCC.mkDerivation` in `fonts.nix`
- Compline theme: `dotfiles/sddm/Themes/compline.conf`, selected via `metadata.desktop`

### Noctalia theming
- Border color: Noctalia user-template (`dotfiles/noctalia/user-templates.toml`) generates
  `dotfiles/hypr/noctalia/border-colors.lua` → sourced after `noctalia-colors.lua` in `hyprland.lua`
- Seed file (`border-colors.lua`) must exist in dotfiles — dofile crashes if file missing before Noctalia runs
- mPrimary (`#b4bcc4`) unchanged — border is `#515761` steel via user-template only
- matugen added to `theming.nix` for Noctalia VS Code extension theme generation

### Claude Code setup
- 27 skills in `dotfiles/claude/skills/<name>/SKILL.md` (invoked via `/<name>`)
- Obsidian MCP via `mcp-server-filesystem` (no nodejs, native nixpkgs binary)
- Statusline: Compline palette (matches starship + Noctalia Compline colorscheme)
- `SessionStart` hook: warns on dirty flake; `PreToolUse` hook: blocks rebuild if flake check fails

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

### Nix build resource limits (thermal + responsiveness)
Currently `max-jobs = "auto"` + `cores = 0` in `modules/nixos/nix/settings.nix` saturates all
CPU cores and ~50% RAM during builds, causing heat and desktop slowdown on XPS 15 9510.
**Next session audit item**: cap `max-jobs` (e.g. 4–6) and `cores` to leave headroom for the desktop.

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

**Runbook when you're ready:**
1. Add a profile file under `modules/nixos/system/apparmor/firefox.profile`
   in complain mode: header `/nix/store/*/bin/firefox flags=(complain) { ... }`
   start permissive — `include <abstractions/base>` + everything firefox-likely
2. Wire into security.nix via `security.apparmor.policies."firefox" = {
     enable = true;
     profile = builtins.readFile ./apparmor/firefox.profile;
   };`
3. Rebuild → use Firefox normally for 1–2 weeks
4. Review `journalctl -k -g apparmor | grep DENIED` to see what was attempted
   and would have been blocked in enforce mode
5. Tighten the profile to remove the over-permissions, swap `flags=(complain)`
   for `flags=()` (= enforce)
6. Rebuild + use; if anything breaks, journal again, loop
7. Repeat for VSCode, distrobox runtime (podman/crun), Signal, Obsidian

Risk: AppArmor on /nix/store paths is finicky — the binary path changes per
rebuild. The `/nix/store/*/bin/X` glob handles it, but some libraries are
resolved via dynamic dispatch that's harder to predict. Always start complain,
never enforce blind.

---

## Deferred

- **Full deep audit (next session)**: every module, dotfile, skill, and config aspect — bring entire setup to next level. Includes Nix build limits, security posture, power tuning, Hyprland/Noctalia polish, dev workflow, performance.
- **2026-05-30**: Switch `nixpkgs` → `nixos-26.05`, `home-manager` → `release-26.05`, bump `stateVersion` to `"26.05"`. Remove the two test-skip overlays in `modules/nixos/nix/settings.nix` (openldap-i686 + tpm2-pytss) — upstream fixes land in the release branch
- **Kali VM**: create manually via virt-manager (intentional — not declarative)
- **nftables deeper ruleset**: low priority for desktop, current INVALID drop + NixOS firewall is sufficient
- **`/proc` hidepid=2**: mount-option (not sysctl), needs a `proc` group exemption to not break sshd/systemd — separate small change with a NixOS VM test
- **OLED idle tiers**: should live in Noctalia `settings.json → idle.customCommands` (JSON array of `{timeout, command, resumeCommand}`), not hypridle. E.g.
  ```json
  "customCommands": "[{\"timeout\":120,\"command\":\"brightnessctl -s set 40%\",\"resumeCommand\":\"brightnessctl -r\"},{\"timeout\":240,\"command\":\"brightnessctl set 10%\",\"resumeCommand\":\"brightnessctl -r\"}]"
  ```
  Pair with `screenOffTimeout: 420` for OLED-friendly early black. Decide as part of the Noctalia-vs-hypridle cleanup above
- **Wal-sync template expansion**: today only kitty follows the wallpaper. Add zathura / starship / hyprlock / yazi / Noctalia templates as you decide each should follow (see `scripts/wal-sync.sh` for the pattern). Noctalia palette switch can be triggered via `noctalia-shell ipc call colorscheme set <name>` per the v4 hooks block
- **NixOS VM tests** for security.nix / ssh.nix / usbguard.nix — see the `/nix-vm-test` skill for the harness; wire into `flake.nix#checks` when written

## Noctalia v4 — all-Noctalia path (resolved in PR #8)

Verified against `noctalia-shell` source (Quickshell singletons):
- `Services/Power/IdleService.qml` — auto-starts on shell init, uses
  native `ext-idle-notify-v1` Wayland protocol, parses
  `Settings.data.idle.customCommands` as a JSON array of
  `{timeout, command, resumeCommand}`, and drives three core stages
  (`screenOffTimeout` → `CompositorService.turnOffMonitors()`,
   `lockTimeout` → `PanelService.lockScreen.active = true`,
   `suspendTimeout` → `CompositorService.suspend()`), each preceded
  by a fade overlay (`fadeDuration` s). Not media-aware — won't
  inhibit during video playback (filed against future Noctalia, not
  our problem to patch).
- `Services/Keyboard/ClipboardService.qml` — auto-spawns
  `appLauncher.clipboardWatchTextCommand` and
  `appLauncher.clipboardWatchImageCommand` (the exact `wl-paste --watch`
  commands), with a 1s watchdog that restarts them if they die.
- `noctalia/plugins/polkit-agent/Main.qml` (enabled via
  `noctalia/plugins.json`) — uses `Quickshell.Services.Polkit`, opens
  a Compline-styled window when an agent request arrives.

Removed in PR #8 (these were duplicating Noctalia services and racing
them — both polkit handlers fought for the DBus name, both idle daemons
fired actions on the same tick, both `wl-paste --watch` processes wrote
the same entries to cliphist):
- `dotfiles/hypr/conf/autostart.lua` — dropped `hyprpolkitagent`,
  `hypridle`, and both `wl-paste --type {text,image} --watch cliphist
  store` lines. Now only `noctalia-shell` + the staggered app starts.
- `home/modules/apps/hyprland.nix` — dropped `hypridle` and
  `hyprpolkitagent` from the package set.
- `dotfiles/hypr/hypridle.conf` — deleted (orphan: no daemon left to
  read it).

Kept: `hyprcursor`, `hyprpicker`, `hyprshot`, `kanshi`. None overlap
with Noctalia; all are on-demand or single-purpose.

### Noctalia clipboard autoPaste — wtype dependency

Noctalia gates `appLauncher.autoPasteClipboard` behind
`ProgramCheckerService.wtypeAvailable` (per
`Modules/Panels/Settings/Tabs/Launcher/ClipboardSubTab.qml`). Without
`wtype` on PATH the toggle is greyed-out in the Noctalia GUI even when
clipboard history is enabled. `wtype` is now in
`modules/nixos/desktop/hyprland.nix` alongside `wl-clipboard` and
`cliphist`. Flip `appLauncher.autoPasteClipboard: true` in the
Noctalia settings to use it.

### Power management — TLP as the sole daemon (confirmed)

Verified state in `modules/nixos/hardware/power.nix`:
- `services.power-profiles-daemon.enable = false` — ppd is off
- `services.tlp.enable = true` — TLP is on
- `PLATFORM_PROFILE_ON_AC = "performance"` /
  `PLATFORM_PROFILE_ON_BAT = "balanced"` — TLP writes
  `/sys/firmware/acpi/platform_profile` (Dell XPS 15 9510 exposes
  this via the `dell-pcc` kernel driver)
- New in PR #8: `CPU_POWER_MAX_ON_AC=65 / _ON_BAT=35` (RAPL PL1 caps)
- `services.thermald.enable` pinned via `mkForce true` so it can't
  get flipped off by a future module import

TLP is the right choice for this machine — ppd doesn't handle battery
charge thresholds (20-80 %), USB autosuspend, ASPM, SATA link-power,
audio power-save, or per-AC/BAT sleep mode (deep vs s2idle) out of the
box; TLP does all of these natively.

Verify post-rebuild:
```bash
tlp-stat -s | grep -E 'TLP_ENABLE|Mode'
cat /sys/firmware/acpi/platform_profile          # current profile
cat /sys/firmware/acpi/platform_profile_choices  # available
sudo tlp-stat -p | grep -E 'platform_profile|policy'
```

### Tuning Noctalia idle for OLED + cybersec hygiene (you decide)

Apply via the Noctalia settings GUI (preferred — it validates) OR by
hand-editing `dotfiles/noctalia/settings.json`. Suggestions for your
panel + workflow:

```jsonc
"idle": {
  "enabled": true,
  "fadeDuration": 5,
  "lockTimeout": 300,        // 5 min — sec-conscious daily driver
  "screenOffTimeout": 420,   // 7 min — OLED-friendly early black
  "suspendTimeout": 1800,    // 30 min — keep
  // OLED brightness-dim tiers BEFORE lock fires
  "customCommands": "[{\"timeout\":120,\"command\":\"brightnessctl -s set 40%\",\"resumeCommand\":\"brightnessctl -r\"},{\"timeout\":240,\"command\":\"brightnessctl set 10%\",\"resumeCommand\":\"brightnessctl -r\"}]"
}
```

That gives you:
- 2 min  → dim to 40 %  (gentle warning)
- 4 min  → dim to 10 %  (deep dim)
- 5 min  → lock          (Noctalia lockTimeout)
- 7 min  → screen off    (Noctalia screenOffTimeout)
- 30 min → suspend       (Noctalia suspendTimeout)
- Resume cancels brightness restores (`brightnessctl -r`).

## Modules added in PR #8

- `modules/nixos/system/hugepages.nix` — opt-in static hugepages for VM work.
  Disabled by default. Flip on in `hosts/nixos/default.nix`:
  ```nix
  my.hugepages = { enable = true; pages = 2048; };
  ```
- `scripts/verify-resume-offset.sh` — confirms `disks.nix` resume_offset
  matches actual swapfile physical start
- `scripts/wal-sync.sh` + `scripts/templates/` — opt-in wallpaper→theme
  pipeline starter

## Claude Code workflow added in PR #8

- 8 new skills under `dotfiles/claude/skills/`: distrobox, threat-model,
  awwwards-audit, web-vitals, blender-cli, nix-vm-test, design-systems,
  laravel-security
- `SessionStart` hook warns when flake.{nix,lock} is uncommitted
- `PreToolUse` hook aborts `nh os switch` / `nixos-rebuild` if
  `nix flake check --no-build` fails
- Statusline now shows distrobox container, battery %, flake-dirty flag
