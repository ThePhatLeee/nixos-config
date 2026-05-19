#!/usr/bin/env bash
# Disk setup for NixOS on this machine.
# Does: partition → LUKS → BTRFS subvolumes → mount → swapfile → hardware config.
# After it finishes, follow the printed instructions to clone and install.
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
[[ -b "$DISK" ]]                    || { echo "Not a block device: $DISK"; exit 1; }

# NVMe partitions are p1/p2; SATA/NVMe-without-p are 1/2
[[ "$DISK" =~ nvme ]] && PART="${DISK}p" || PART="$DISK"
EFI="${PART}1"
LUKS="${PART}2"

echo ""
echo "  Disk:  $DISK  ($EFI = EFI, $LUKS = LUKS)"
echo ""
read -rp "Type YES to wipe $DISK and continue: " CONFIRM
[[ $CONFIRM == "YES" ]] || { echo "Aborted."; exit 1; }

# ── 1. Partition ──────────────────────────────────────────────────────────────
echo ""
echo "==> [1/6] Partitioning..."
sgdisk -Z "$DISK"
sgdisk -n 1:0:+1G -t 1:ef00 -c 1:ESP  "$DISK"
sgdisk -n 2:0:0   -t 2:8309 -c 2:luks "$DISK"
partprobe "$DISK"
sleep 1

# ── 2. EFI ────────────────────────────────────────────────────────────────────
echo ""
echo "==> [2/6] Formatting EFI..."
mkfs.vfat -F 32 -n boot "$EFI"

# ── 3. LUKS ───────────────────────────────────────────────────────────────────
echo ""
echo "==> [3/6] Setting up LUKS (you will set your passphrase now)..."
cryptsetup luksFormat --type luks2 "$LUKS"
cryptsetup open --allow-discards \
  --perf-no_read_workqueue --perf-no_write_workqueue \
  "$LUKS" cryptroot

# ── 4. BTRFS + subvolumes ─────────────────────────────────────────────────────
echo ""
echo "==> [4/6] Creating BTRFS subvolumes..."
mkfs.btrfs -L nixos -f /dev/mapper/cryptroot
mount /dev/mapper/cryptroot /mnt

for sv in @ @home @nix @log @cache @tmp @snapshots @persist @swap; do
  btrfs subvolume create "/mnt/$sv"
done
# nodatacow required for swapfile, recommended for logs/cache/tmp
chattr +C /mnt/@log /mnt/@cache /mnt/@tmp /mnt/@swap

umount /mnt

# ── 5. Mount everything ───────────────────────────────────────────────────────
echo ""
echo "==> [5/6] Mounting to /mnt..."
BASE="noatime,space_cache=v2,ssd,discard=async"
mount -o "subvol=@,$BASE,compress=zstd:3"            /dev/mapper/cryptroot /mnt
mkdir -p /mnt/{boot,home,nix,var/log,var/cache,tmp,.snapshots,persist,swap}
mount "$EFI" /mnt/boot
mount -o "subvol=@home,$BASE,compress=zstd:3"        /dev/mapper/cryptroot /mnt/home
mount -o "subvol=@nix,$BASE,compress=zstd:1"         /dev/mapper/cryptroot /mnt/nix
mount -o "subvol=@log,$BASE,nodatacow"               /dev/mapper/cryptroot /mnt/var/log
mount -o "subvol=@cache,$BASE,nodatacow"             /dev/mapper/cryptroot /mnt/var/cache
mount -o "subvol=@tmp,$BASE,nodatacow"               /dev/mapper/cryptroot /mnt/tmp
mount -o "subvol=@snapshots,$BASE,compress=zstd:3"   /dev/mapper/cryptroot /mnt/.snapshots
mount -o "subvol=@persist,$BASE,compress=zstd:3"     /dev/mapper/cryptroot /mnt/persist
mount -o "subvol=@swap,$BASE,nodatacow"              /dev/mapper/cryptroot /mnt/swap

# ── 6. Swapfile + hardware config ────────────────────────────────────────────
echo ""
echo "==> [6/6] Swapfile + hardware config..."
btrfs filesystem mkswapfile --size 16G /mnt/swap/swapfile
nixos-generate-config --no-filesystems --root /mnt

OFFSET=$(btrfs inspect-internal map-swapfile -r /mnt/swap/swapfile 2>/dev/null \
  | awk '/physical/{print $NF}') || true

# ── Done — print next steps ───────────────────────────────────────────────────
echo ""
echo "============================================================"
echo "  Disk setup complete. Now:"
echo ""
echo "  1. Clone config:"
echo "       nix-shell -p git --run \\"
echo "         'git clone https://github.com/ThePhatLeee/nixos-config /tmp/nixos-config'"
echo ""
echo "  2. Copy the generated hardware config into the repo:"
echo "       cp /mnt/etc/nixos/hardware-configuration.nix \\"
echo "          /tmp/nixos-config/hosts/nixos/hardware-configuration.nix"
echo ""
if [[ "$OFFSET" =~ ^[0-9]+$ ]]; then
echo "  3. Enable hibernation (resume_offset = $OFFSET):"
echo "       Edit /tmp/nixos-config/modules/nixos/disks.nix"
echo "       Uncomment the two boot.resumeDevice / boot.kernelParams lines"
echo "       and set resume_offset=$OFFSET"
echo ""
else
echo "  3. Hibernation offset could not be read automatically."
echo "     Get it manually: btrfs inspect-internal map-swapfile -r /mnt/swap/swapfile"
echo "     Then uncomment the two lines in modules/nixos/disks.nix."
echo ""
fi
echo "  4. Install:"
echo "       mkdir -p /mnt/home/phatle"
echo "       cp -r /tmp/nixos-config /mnt/home/phatle/nixos-config"
echo "       nixos-install --flake /mnt/home/phatle/nixos-config#nixos --no-root-passwd"
echo ""
echo "  5. Reboot — LUKS passphrase prompt then SDDM (login: phatle / nixos)"
echo "============================================================"
