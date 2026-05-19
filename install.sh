#!/usr/bin/env bash
# NixOS install script — run after cloning the repo to /tmp/nixos-config
#
# Usage (from NixOS ISO):
#   sudo bash /tmp/nixos-config/install.sh
#
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
SWAP_SIZE=16G   # match or exceed your RAM for full hibernation

# ── Disk selection ────────────────────────────────────────────────────────────
echo ""
echo "Available disks:"
lsblk -d -o NAME,SIZE,MODEL | grep -v "loop"
echo ""
read -rp "Target disk [nvme0n1]: " DISK_INPUT
DISK="/dev/${DISK_INPUT:-nvme0n1}"
echo ""
echo "  Will wipe and install to: $DISK"
echo "  Swap size: $SWAP_SIZE"
echo "  Config:    $REPO"
echo ""
read -rp "Type YES to continue: " CONFIRM
[[ $CONFIRM == "YES" ]] || { echo "Aborted."; exit 1; }

# Patch disko.nix with the chosen disk
sed -i "s|device = \"/dev/[^\"]*\";.*# Samsung|device = \"$DISK\";    # Samsung|" "$REPO/disko.nix" 2>/dev/null || true
# If the comment doesn't match, try without it
grep -q "device = \"$DISK\"" "$REPO/disko.nix" || \
  sed -i "s|device = \"/dev/[^\"]*\";|device = \"$DISK\";|" "$REPO/disko.nix"

# ── Step 1: disko (partition, encrypt, format, mount) ────────────────────────
echo ""
echo "==> [1/6] Running disko..."
sudo nix --extra-experimental-features 'nix-command flakes' run \
  github:nix-community/disko -- --mode disko "$REPO/disko.nix"

# ── Step 2: Hardware config (must match THIS machine) ────────────────────────
echo ""
echo "==> [2/6] Regenerating hardware-configuration.nix..."
sudo nixos-generate-config --no-filesystems --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix \
   "$REPO/hosts/nixos/hardware-configuration.nix"

# ── Step 3: Swapfile ─────────────────────────────────────────────────────────
echo ""
echo "==> [3/6] Creating swapfile ($SWAP_SIZE)..."
sudo btrfs filesystem mkswapfile --size "$SWAP_SIZE" /mnt/swap/swapfile

# ── Step 4: Compute resume offset and patch disks.nix ────────────────────────
echo ""
echo "==> [4/6] Computing hibernation resume offset..."
OFFSET=$(sudo btrfs inspect-internal map-swapfile -r /mnt/swap/swapfile \
  | awk '/physical start/{print $NF}')
echo "    resume_offset = $OFFSET"

# Uncomment the two hibernation lines and fill in the offset
sed -i \
  -e "/# boot\.resumeDevice/s/^  # /  /" \
  -e "/# boot\.kernelParams = \[/s/^  # /  /" \
  -e "s/REPLACE_WITH_ACTUAL_OFFSET/$OFFSET/" \
  "$REPO/modules/nixos/disks.nix"

# ── Step 5: Copy repo to installed system ────────────────────────────────────
echo ""
echo "==> [5/6] Copying config to /mnt/home/phatle/nixos-config..."
mkdir -p /mnt/home/phatle
cp -r "$REPO" /mnt/home/phatle/nixos-config

# ── Step 6: Install ──────────────────────────────────────────────────────────
echo ""
echo "==> [6/6] Installing NixOS..."
sudo nixos-install \
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
