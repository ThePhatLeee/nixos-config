# disko.nix — Declarative LUKS2 + BTRFS layout
#
# Used ONLY during install — run with:
#   sudo nix run github:nix-community/disko -- --mode disko /path/to/disko.nix
#
# Confirm your disk with lsblk before running. Default: /dev/nvme0n1 (Samsung 990 PRO).
#
# Layout (everything except EFI is inside LUKS):
#   p1 — EFI  1G  FAT32  /boot          (unencrypted — bootloader only)
#   p2 — LUKS2 → BTRFS (rest of disk)
#          @           /
#          @home       /home
#          @nix        /nix
#          @log        /var/log     nodatacow
#          @cache      /var/cache   nodatacow
#          @tmp        /tmp         nodatacow
#          @snapshots  /.snapshots
#          @persist    /persist
#          @swap       /swap        nodatacow — swapfile lives here
#
# No separate swap partition — swapfile inside the encrypted BTRFS.
# zram (primary, fast) + /swap/swapfile (disk fallback + hibernation).
{ ... }:

{
  disko.devices = {
    disk.main = {
      type   = "disk";
      device = "/dev/nvme0n1";    # Samsung 990 PRO — confirm with lsblk

      content = {
        type = "gpt";
        partitions = {

          ESP = {
            priority = 1;
            name     = "ESP";
            start    = "1MiB";
            end      = "1GiB";
            type     = "EF00";
            content  = {
              type         = "filesystem";
              format       = "vfat";
              mountpoint   = "/boot";
              mountOptions = [ "fmask=0022" "dmask=0022" ];
            };
          };

          luks = {
            size    = "100%";
            content = {
              type = "luks";
              name = "cryptroot";

              # SSD: bypass read/write workqueues (reduces NVMe latency)
              extraOpenArgs = [
                "--allow-discards"
                "--perf-no_read_workqueue"
                "--perf-no_write_workqueue"
              ];
              settings.allowDiscards = true;

              content = {
                type      = "btrfs";
                extraArgs = [ "-L" "nixos" "-f" ];

                subvolumes = {
                  "@" = {
                    mountpoint   = "/";
                    mountOptions = [ "noatime" "compress=zstd:3" "space_cache=v2" "ssd" "discard=async" ];
                  };
                  "@home" = {
                    mountpoint   = "/home";
                    mountOptions = [ "noatime" "compress=zstd:3" "space_cache=v2" "ssd" "discard=async" ];
                  };
                  "@nix" = {
                    mountpoint   = "/nix";
                    mountOptions = [ "noatime" "compress=zstd:1" "space_cache=v2" "ssd" "discard=async" ];
                  };
                  "@log" = {
                    mountpoint   = "/var/log";
                    mountOptions = [ "noatime" "nodatacow" "space_cache=v2" "ssd" "discard=async" ];
                  };
                  "@cache" = {
                    mountpoint   = "/var/cache";
                    mountOptions = [ "noatime" "nodatacow" "space_cache=v2" "ssd" "discard=async" ];
                  };
                  "@tmp" = {
                    mountpoint   = "/tmp";
                    mountOptions = [ "noatime" "nodatacow" "space_cache=v2" "ssd" "discard=async" ];
                  };
                  "@snapshots" = {
                    mountpoint   = "/.snapshots";
                    mountOptions = [ "noatime" "compress=zstd:3" "space_cache=v2" "ssd" "discard=async" ];
                  };
                  "@persist" = {
                    mountpoint   = "/persist";
                    mountOptions = [ "noatime" "compress=zstd:3" "space_cache=v2" "ssd" "discard=async" ];
                  };
                  # Swap subvolume — nodatacow, no compression (required for swapfiles)
                  "@swap" = {
                    mountpoint   = "/swap";
                    mountOptions = [ "noatime" "nodatacow" "space_cache=v2" "ssd" "discard=async" ];
                  };
                };
              };
            };
          };

        };
      };
    };
  };
}
