# Hardware-only configuration — kernel modules, CPU microcode, platform.
# Filesystem and LUKS declarations live in modules/nixos/disks.nix.
# Regenerate with: nixos-generate-config --no-filesystems --root /mnt
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "uas" "sd_mod" "rtsx_pci_sdmmc" ];
  # i915 enables early KMS so the display is active during initrd (LUKS prompt visible).
  # Replace with "amdgpu" or "nouveau" if not using Intel iGPU.
  boot.initrd.kernelModules          = [ "i915" ];
  boot.kernelModules                 = [ "kvm-intel" ];
  boot.extraModulePackages           = [ ];

  nixpkgs.hostPlatform               = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
