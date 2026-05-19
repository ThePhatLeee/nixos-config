{ config, lib, ... }:

# LUKS2 device + BTRFS filesystem declarations + swapfile + hibernation resume.
# Physical layout is declared in disko.nix (used once during install).
# TPM2 auto-unlock is in tpm.nix (import after first boot + enrollment).
{
  boot.initrd.luks.devices."cryptroot" = {
    device           = "/dev/disk/by-partlabel/luks";
    allowDiscards    = true;    # SSD TRIM through LUKS
    bypassWorkqueues = true;    # reduce NVMe latency (kernel 5.18+)
  };

  boot.initrd.supportedFilesystems = [ "btrfs" ];
  boot.supportedFilesystems        = [ "btrfs" ];

  fileSystems =
    let
      btrfsOpts = [ "noatime" "compress=zstd:3" "space_cache=v2" "ssd" "discard=async" ];
      nixOpts   = [ "noatime" "compress=zstd:1" "space_cache=v2" "ssd" "discard=async" ];
      cowOpts   = [ "noatime" "nodatacow"        "space_cache=v2" "ssd" "discard=async" ];
      dev       = "/dev/mapper/cryptroot";
    in {
      "/"           = { device = dev; fsType = "btrfs"; options = [ "subvol=@"          ] ++ btrfsOpts; };
      "/home"       = { device = dev; fsType = "btrfs"; options = [ "subvol=@home"      ] ++ btrfsOpts; };
      "/nix"        = { device = dev; fsType = "btrfs"; options = [ "subvol=@nix"       ] ++ nixOpts; };
      "/var/log"    = { device = dev; fsType = "btrfs"; options = [ "subvol=@log"       ] ++ cowOpts; neededForBoot = true; };
      "/var/cache"  = { device = dev; fsType = "btrfs"; options = [ "subvol=@cache"     ] ++ cowOpts; };
      "/tmp"        = { device = dev; fsType = "btrfs"; options = [ "subvol=@tmp"       ] ++ cowOpts; };
      "/.snapshots" = { device = dev; fsType = "btrfs"; options = [ "subvol=@snapshots" ] ++ btrfsOpts; };
      "/persist"    = { device = dev; fsType = "btrfs"; options = [ "subvol=@persist"   ] ++ btrfsOpts; neededForBoot = true; };
      "/swap"       = { device = dev; fsType = "btrfs"; options = [ "subvol=@swap"      ] ++ cowOpts; };
      "/boot"       = { device = "/dev/disk/by-partlabel/ESP"; fsType = "vfat"; options = [ "fmask=0022" "dmask=0022" ]; };
    };

  # Swapfile inside the encrypted BTRFS — all swap data stays inside LUKS.
  # The file is created manually during install (see install guide step 5).
  # zram (high priority) runs first; this is the disk fallback + hibernation target.
  swapDevices = [{
    device = "/swap/swapfile";
  }];

  # Hibernation — resume from the encrypted BTRFS swapfile.
  # resume_offset: computed once during install:
  #   sudo btrfs inspect-internal map-swapfile -r /mnt/swap/swapfile
  # Copy the "physical start" number and replace 0 below, then commit and rebuild.
  boot.resumeDevice = "/dev/mapper/cryptroot";
  boot.kernelParams = [ "resume_offset=0" ];    # ← replace 0 with actual offset
}
