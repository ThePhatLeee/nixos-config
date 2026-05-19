{ config, lib, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Always run the latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Force VMD to load unconditionally in initrd.
  # On Intel 11th-gen+ laptops the NVMe is behind a VMD (Volume Management
  # Device) controller. VMD is in availableKernelModules (load if detected)
  # but the NVMe isn't visible until VMD loads first — chicken-and-egg that
  # causes "Timed out waiting for /dev/disk/by-partlabel/luks" in initrd.
  # kernelModules forces the load before any device enumeration happens.
  boot.initrd.kernelModules = [ "vmd" ];

  # Silent boot — clean tty on startup.
  # No "splash" here: Plymouth is not enabled, and "splash" without it blacks out
  # the framebuffer so the LUKS passphrase prompt never becomes visible.
  boot.consoleLogLevel = 3;
  boot.kernelParams = [ "quiet" "loglevel=3" ];
}
