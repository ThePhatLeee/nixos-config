#!/usr/bin/env bash
# Disko — partition, encrypt, format and mount the disk.
# Run from the NixOS ISO. After this completes, run nixos-install yourself.
#
# Usage:
#   sudo bash /tmp/nixos-config/install.sh
#
set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "Run as root: sudo bash $0"; exit 1; }

REPO="$(cd "$(dirname "$0")" && pwd)"
SWAP_SIZE=16G   # match or exceed your RAM for full hibernation support

# ── Disk selection ─────────────────────────────────────────────────────────────
echo ""
echo "Available disks:"
lsblk -d -o NAME,SIZE,MODEL | grep -v loop
echo ""
read -rp "Target disk [nvme0n1]: " DISK_INPUT
DISK_INPUT="${DISK_INPUT:-nvme0n1}"
DISK_INPUT="${DISK_INPUT#/dev/}"   # strip /dev/ if user typed full path

[[ "$DISK_INPUT" =~ ^[a-zA-Z0-9._-]+$ ]] || { echo "Invalid disk: $DISK_INPUT"; exit 1; }

DISK="/dev/$DISK_INPUT"
[[ -b "$DISK" ]] || { echo "Not a block device: $DISK  (check lsblk)"; exit 1; }

echo ""
echo "  Disk:  $DISK"
echo "  Swap:  $SWAP_SIZE"
echo ""
read -rp "Type YES to continue (THIS WIPES $DISK): " CONFIRM
[[ $CONFIRM == "YES" ]] || { echo "Aborted."; exit 1; }

# Patch disko.nix with the chosen disk before running it
sed -i "s|device = \"/dev/[^\"]*\";|device = \"$DISK\";|" "$REPO/disko.nix"

# ── 1. Disko ───────────────────────────────────────────────────────────────────
echo ""
echo "==> [1/3] disko — partitioning, LUKS, BTRFS, mounting to /mnt..."
nix --extra-experimental-features 'nix-command flakes' run \
  github:nix-community/disko -- --mode disko "$REPO/disko.nix"

# ── 2. Swapfile ────────────────────────────────────────────────────────────────
echo ""
echo "==> [2/3] Creating swapfile ($SWAP_SIZE)..."
btrfs filesystem mkswapfile --size "$SWAP_SIZE" /mnt/swap/swapfile

# ── 3. Resume offset ───────────────────────────────────────────────────────────
echo ""
echo "==> [3/3] Computing hibernation resume offset..."
OFFSET=$(btrfs inspect-internal map-swapfile -r /mnt/swap/swapfile 2>/dev/null \
  | awk '/physical/{print $NF}') || true

# ── Done ───────────────────────────────────────────────────────────────────────
echo ""
echo "============================================================"
echo "  /mnt is ready."
echo ""
if [[ "$OFFSET" =~ ^[0-9]+$ ]]; then
  echo "  Hibernation resume offset: $OFFSET"
  echo "  Update modules/nixos/system/disks.nix before nixos-install:"
  echo ""
  echo "    boot.kernelParams = [ \"resume_offset=$OFFSET\" ];"
  echo ""
else
  echo "  WARNING: could not compute resume offset."
  echo "  Hibernation will be disabled until you set it manually."
  echo "  After first boot: sudo btrfs inspect-internal map-swapfile -r /swap/swapfile"
  echo ""
fi
echo "  Next:"
echo "    nixos-install --flake $REPO#nixos --no-root-passwd"
echo "    reboot"
echo "============================================================"
