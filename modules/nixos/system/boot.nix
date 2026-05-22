{ lib, pkgs, ... }:

{
  # systemd-boot disabled — lanzaboote takes over (signs bootloader + kernel for Secure Boot).
  # lanzaboote.nixosModules.lanzaboote is imported in flake.nix.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.lanzaboote = {
    enable              = true;
    pkiBundle           = "/var/lib/sbctl";
    configurationLimit  = 3;
  };

  environment.systemPackages = [ pkgs.sbctl ];

  # Always run the latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Force VMD to load unconditionally in initrd.
  # On Intel 11th-gen+ laptops the NVMe is behind a VMD (Volume Management
  # Device) controller. VMD is in availableKernelModules (load if detected)
  # but the NVMe isn't visible until VMD loads first — chicken-and-egg that
  # causes "Timed out waiting for /dev/disk/by-partlabel/luks" in initrd.
  # kernelModules forces the load before any device enumeration happens.
  boot.initrd.kernelModules = [ "vmd" ];

  # Silent boot — Plymouth adds "splash" automatically via desktop/plymouth.nix.
  boot.consoleLogLevel = 3;
  boot.kernelParams = [ "quiet" "loglevel=3" ];

  boot.tmp.useTmpfs  = true;
  boot.tmp.tmpfsSize = "4G";

  # zstd decompresses ~3× faster than gzip — noticeably shorter initrd load time
  boot.initrd.compressor     = "zstd";
  boot.initrd.compressorArgs = [ "-19" "-T0" ];
}
