{ config, lib, ... }:

# LUKS2 device + BTRFS filesystem declarations + swapfile + hibernation resume.
# Physical layout is declared in disko.nix (used once during install).
# TPM2 auto-unlock is in tpm.nix (import after first boot + enrollment).
{
  boot.initrd.luks.devices."cryptroot" = {
    device           = "/dev/disk/by-uuid/b7fc6301-db05-42d3-9678-b5ef62552f2e";
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
      "/.snapshots" = { device = dev; fsType = "btrfs"; options = [ "subvol=@snapshots" ] ++ btrfsOpts; };
      "/persist"    = { device = dev; fsType = "btrfs"; options = [ "subvol=@persist"   ] ++ btrfsOpts; neededForBoot = true; };
      "/swap"       = { device = dev; fsType = "btrfs"; options = [ "subvol=@swap"      ] ++ cowOpts; };
      "/boot"       = { device = "/dev/disk/by-uuid/6973-0B60"; fsType = "vfat"; options = [ "fmask=0022" "dmask=0022" ]; };
    };

  # Swapfile inside the encrypted BTRFS — all swap data stays inside LUKS.
  # The file is created manually during install (see install guide step 5).
  # zram (high priority) runs first; this is the disk fallback + hibernation target.
  swapDevices = [{
    device = "/swap/swapfile";
  }];

  # Hibernation — resume from the encrypted BTRFS swapfile.
  #
  # SETUP REQUIRED before enabling:
  #   During install (target mounted at /mnt):
  #     sudo btrfs inspect-internal map-swapfile -r /mnt/swap/swapfile
  #   After a running boot (filesystem mounted at /):
  #     sudo btrfs inspect-internal map-swapfile -r /swap/swapfile
  #   Copy the "physical start" number, uncomment the two lines below,
  #   replace REPLACE_WITH_ACTUAL_OFFSET, and nixos-rebuild switch.
  #
  boot.resumeDevice = "/dev/mapper/cryptroot";
  boot.kernelParams = [ "resume_offset=533760" ];
}
