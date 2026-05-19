#!/usr/bin/env bash
# NixOS install script — run after cloning the repo to /tmp/nixos-config
#
# Usage (from NixOS ISO):
#   sudo bash /tmp/nixos-config/install.sh
#
set -euo pipefail

# ── Root check ────────────────────────────────────────────────────────────────
[[ $EUID -eq 0 ]] || { echo "Run as root: sudo bash $0"; exit 1; }

REPO="$(cd "$(dirname "$0")" && pwd)"
SWAP_SIZE=16G   # match or exceed your RAM for full hibernation

# ── Disk selection ────────────────────────────────────────────────────────────
echo ""
echo "Available disks:"
lsblk -d -o NAME,SIZE,MODEL | grep -v "loop"
echo ""
read -rp "Target disk [nvme0n1]: " DISK_INPUT

# Strip /dev/ prefix if the user typed a full path (e.g. /dev/sda → sda)
DISK_INPUT="${DISK_INPUT:-nvme0n1}"
DISK_INPUT="${DISK_INPUT#/dev/}"

# Validate: only safe characters, no path traversal
[[ "$DISK_INPUT" =~ ^[a-zA-Z0-9._-]+$ ]] \
  || { echo "Invalid disk name: $DISK_INPUT"; exit 1; }

DISK="/dev/$DISK_INPUT"

# Verify it is actually a block device before doing anything destructive
[[ -b "$DISK" ]] || { echo "Not a block device: $DISK  (check lsblk)"; exit 1; }

echo ""
echo "  Will wipe and install to: $DISK"
echo "  Swap size:  $SWAP_SIZE"
echo "  Config:     $REPO"
echo ""
read -rp "Type YES to continue: " CONFIRM
[[ $CONFIRM == "YES" ]] || { echo "Aborted."; exit 1; }

# Patch disko.nix with the chosen disk (DISK_INPUT is already validated safe)
sed -i "s|device = \"/dev/[^\"]*\";|device = \"$DISK\";|" "$REPO/disko.nix"

# ── Step 1: disko (partition, encrypt, format, mount) ────────────────────────
echo ""
echo "==> [1/6] Running disko..."
# disko is not a flake input here; pin it by adding it to flake.nix inputs if
# reproducibility matters. For now the ISO-time nix run uses the nixpkgs cache.
nix --extra-experimental-features 'nix-command flakes' run \
  github:nix-community/disko -- --mode disko "$REPO/disko.nix"

# ── Step 2: Hardware config (must match THIS machine) ────────────────────────
echo ""
echo "==> [2/6] Regenerating hardware-configuration.nix..."
nixos-generate-config --no-filesystems --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix \
   "$REPO/hosts/nixos/hardware-configuration.nix"

# ── Step 3: Swapfile ─────────────────────────────────────────────────────────
echo ""
echo "==> [3/6] Creating swapfile ($SWAP_SIZE)..."
btrfs filesystem mkswapfile --size "$SWAP_SIZE" /mnt/swap/swapfile

# ── Step 4: Compute resume offset and patch disks.nix ────────────────────────
echo ""
echo "==> [4/6] Computing hibernation resume offset..."
# || true: tolerate btrfs failure so set -e doesn't abort before the fallback.
# /physical/ matches "physical start:" across btrfs-progs versions.
OFFSET=$(btrfs inspect-internal map-swapfile -r /mnt/swap/swapfile 2>/dev/null \
  | awk '/physical/{print $NF}') || true

if [[ "$OFFSET" =~ ^[0-9]+$ ]]; then
  echo "    resume_offset = $OFFSET"
  sed -i \
    -e "/# boot\.resumeDevice/s/^  # /  /" \
    -e "/# boot\.kernelParams = \[/s/^  # /  /" \
    -e "s/REPLACE_WITH_ACTUAL_OFFSET/$OFFSET/" \
    "$REPO/modules/nixos/disks.nix"
else
  echo "    WARNING: could not determine resume_offset (got: '${OFFSET:-empty}')"
  echo "    Hibernation left disabled. Enable manually after install:"
  echo "      sudo btrfs inspect-internal map-swapfile -r /swap/swapfile"
  echo "    Then uncomment the two boot.resumeDevice / boot.kernelParams lines"
  echo "    in modules/nixos/disks.nix and nixos-rebuild switch."
fi

# ── Step 5: Copy repo to installed system ────────────────────────────────────
echo ""
echo "==> [5/6] Copying config to /mnt/home/phatle/nixos-config..."
mkdir -p /mnt/home/phatle
# Remove any previous partial copy so cp is idempotent on reruns
rm -rf /mnt/home/phatle/nixos-config
cp -r "$REPO" /mnt/home/phatle/nixos-config

# ── Step 6: Install ──────────────────────────────────────────────────────────
echo ""
echo "==> [6/6] Installing NixOS..."
nixos-install \
  --flake /mnt/home/phatle/nixos-config#nixos \
  --no-root-passwd

# ── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo "=============================="
echo "  Install complete!"
echo "  After reboot: LUKS passphrase prompt → SDDM"
echo "  Then: sudo chown -R phatle:users ~/nixos-config"
echo "=============================="
echo ""
read -rp "Reboot now? [Y/n]: " REBOOT
[[ ${REBOOT:-Y} =~ ^[Yy]$ ]] && reboot
