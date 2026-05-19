#!/usr/bin/env bash
# Disk setup for NixOS.
# Does the painful manual work: partition → LUKS → BTRFS → mount → swap → nixos-install.
# After reboot, clone this repo and run: nixos-rebuild switch --flake ~/nixos-config#nixos
#
# Usage: sudo bash install.sh
#
set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "Run as root: sudo bash $0"; exit 1; }

# ── Disk selection ────────────────────────────────────────────────────────────
echo ""
echo "Available disks:"
lsblk -d -o NAME,SIZE,MODEL | grep -v loop
echo ""
read -rp "Target disk [nvme0n1]: " INPUT
INPUT="${INPUT:-nvme0n1}"
INPUT="${INPUT#/dev/}"
[[ "$INPUT" =~ ^[a-zA-Z0-9._-]+$ ]] || { echo "Invalid disk name: $INPUT"; exit 1; }
DISK="/dev/$INPUT"
[[ -b "$DISK" ]] || { echo "Not a block device: $DISK"; exit 1; }

# Partition suffix: names ending in a digit (nvme0n1, mmcblk0) use pN; others (sda) use N
[[ "$INPUT" =~ [0-9]$ ]] && PART="${DISK}p" || PART="$DISK"
EFI="${PART}1"
LUKS="${PART}2"

echo ""
echo "  Disk:  $DISK"
echo "  EFI:   $EFI  (1G, FAT32, /boot)"
echo "  LUKS:  $LUKS  (rest, LUKS2 → BTRFS)"
echo ""
read -rp "Type YES to wipe $DISK and continue: " CONFIRM
[[ $CONFIRM == "YES" ]] || { echo "Aborted."; exit 1; }

# ── 1. Partition ──────────────────────────────────────────────────────────────
echo ""
echo "==> [1/7] Partitioning $DISK..."
sgdisk -Z "$DISK"
sgdisk -n 1:0:+1G -t 1:ef00 -c 1:ESP  "$DISK"
sgdisk -n 2:0:0   -t 2:8309 -c 2:luks "$DISK"
partprobe "$DISK"
sleep 1

# ── 2. EFI ────────────────────────────────────────────────────────────────────
echo ""
echo "==> [2/7] Formatting EFI..."
mkfs.vfat -F 32 -n boot "$EFI"

# ── 3. LUKS ───────────────────────────────────────────────────────────────────
echo ""
echo "==> [3/7] Setting up LUKS2 (enter your disk passphrase when prompted)..."
cryptsetup luksFormat --type luks2 "$LUKS"
cryptsetup open --allow-discards \
  --perf-no_read_workqueue --perf-no_write_workqueue \
  "$LUKS" cryptroot

# ── 4. BTRFS + subvolumes ─────────────────────────────────────────────────────
echo ""
echo "==> [4/7] Creating BTRFS and subvolumes..."
mkfs.btrfs -L nixos -f /dev/mapper/cryptroot
mount /dev/mapper/cryptroot /mnt

for sv in @ @home @nix @log @cache @tmp @snapshots @persist @swap; do
  btrfs subvolume create "/mnt/$sv"
done
# nodatacow required for swapfile and recommended for logs/cache/tmp
chattr +C /mnt/@log /mnt/@cache /mnt/@tmp /mnt/@swap
umount /mnt

# ── 5. Mount ──────────────────────────────────────────────────────────────────
echo ""
echo "==> [5/7] Mounting subvolumes to /mnt..."
BASE="noatime,space_cache=v2,ssd,discard=async"
mount -o "subvol=@,$BASE,compress=zstd:3"          /dev/mapper/cryptroot /mnt
mkdir -p /mnt/{boot,home,nix,var/log,var/cache,tmp,.snapshots,persist,swap}
mount "$EFI" /mnt/boot
mount -o "subvol=@home,$BASE,compress=zstd:3"      /dev/mapper/cryptroot /mnt/home
mount -o "subvol=@nix,$BASE,compress=zstd:1"       /dev/mapper/cryptroot /mnt/nix
mount -o "subvol=@log,$BASE,nodatacow"             /dev/mapper/cryptroot /mnt/var/log
mount -o "subvol=@cache,$BASE,nodatacow"           /dev/mapper/cryptroot /mnt/var/cache
mount -o "subvol=@tmp,$BASE,nodatacow"             /dev/mapper/cryptroot /mnt/tmp
mount -o "subvol=@snapshots,$BASE,compress=zstd:3" /dev/mapper/cryptroot /mnt/.snapshots
mount -o "subvol=@persist,$BASE,compress=zstd:3"   /dev/mapper/cryptroot /mnt/persist
mount -o "subvol=@swap,$BASE,nodatacow"            /dev/mapper/cryptroot /mnt/swap

# ── 6. Swapfile ───────────────────────────────────────────────────────────────
echo ""
echo "==> [6/7] Creating 16G swapfile..."
btrfs filesystem mkswapfile --size 16G /mnt/swap/swapfile

# Get resume offset now while we still have the installer context
OFFSET=$(btrfs inspect-internal map-swapfile -r /mnt/swap/swapfile 2>/dev/null \
  | awk '/physical/{print $NF}') || true

# ── 7. Generate config + install ─────────────────────────────────────────────
echo ""
echo "==> [7/7] Generating hardware config and running nixos-install..."
echo "    (You will be prompted to set the ROOT password)"
echo ""
nixos-generate-config --root /mnt

# Force vmd into kernelModules so NVMe is visible in initrd on Intel VMD laptops.
# nixos-generate-config puts it in availableKernelModules (load-on-detect) but
# the NVMe isn't detectable until after vmd loads — kernelModules forces it first.
HW=/mnt/etc/nixos/hardware-configuration.nix
if grep -q '"vmd"' "$HW"; then
  sed -i 's/boot\.initrd\.kernelModules\s*=\s*\[/boot.initrd.kernelModules = [ "vmd" /' "$HW" \
    || echo "  Note: manually add vmd to boot.initrd.kernelModules if first boot shows luks timeout"
fi

nixos-install --root /mnt

# Set phatle's password now inside the chroot — no plaintext password in config or git
echo ""
echo "==> Set password for user 'phatle' (you will use this to log in after reboot):"
nixos-enter --root /mnt -- passwd phatle

# ── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo "============================================================"
echo "  Install complete!"
echo ""
echo "  After reboot, log in as ROOT and run these commands:"
echo ""
echo "  1. Clone config:"
echo "       nix-shell -p git --run \\"
echo "         'git clone https://github.com/ThePhatLeee/nixos-config ~/nixos-config'"
echo ""
echo "  2. Copy hardware config (without filesystem UUIDs — the flake manages those):"
echo "       nixos-generate-config --no-filesystems"
echo "       cp /etc/nixos/hardware-configuration.nix \\"
echo "          ~/nixos-config/hosts/nixos/hardware-configuration.nix"
echo ""
if [[ "$OFFSET" =~ ^[0-9]+$ ]]; then
echo "  3. Enable hibernation (resume_offset = $OFFSET):"
echo "       Edit ~/nixos-config/modules/nixos/disks.nix"
echo "       Uncomment boot.resumeDevice and boot.kernelParams lines"
echo "       Set resume_offset=$OFFSET"
echo ""
else
echo "  3. Enable hibernation (optional):"
echo "       btrfs inspect-internal map-swapfile -r /swap/swapfile"
echo "       Edit ~/nixos-config/modules/nixos/disks.nix"
echo "       Uncomment the two lines and set the printed offset"
echo ""
fi
echo "  4. Switch to flake config:"
echo "       sudo nixos-rebuild switch --flake ~/nixos-config#nixos"
echo ""
echo "  SDDM starts automatically after step 4."
echo "  Login at SDDM: phatle + the password you just set above."
echo "============================================================"
echo ""
read -rp "Reboot now? [Y/n]: " REBOOT
[[ ${REBOOT:-Y} =~ ^[Yy]$ ]] && reboot
