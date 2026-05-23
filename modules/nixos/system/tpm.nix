{ config, lib, pkgs, ... }:

# TPM2 auto-unlock for LUKS — import this AFTER first successful passphrase boot
# and after running systemd-cryptenroll (see tpm-enroll guide below).
#
# Enrollment (run once after first boot):
#   sudo systemd-cryptenroll \
#     --tpm2-device=auto \
#     --tpm2-pcrs=2+7+15 \
#     /dev/disk/by-partlabel/luks
#
# PCR policy:
#   PCR 2  — Option ROMs / external firmware
#   PCR 7  — Secure Boot state (key trust)
#   PCR 15 — systemd OS phase (stable across NixOS generation switches)
#   PCR 0  — UEFI firmware code (DROPPED: changes on every BIOS update → lockout.
#             Re-add only if you accept re-enrolling after every Dell firmware push.)
#   PCR 12 — kernel command line (DO NOT add unless you re-enroll on every rebuild
#             that changes kernel params — NixOS generation switches change this)
#
# NOTE: TPM policy is baked into the LUKS slot at enroll time. Changing the PCR
# set in this file does NOT retroactively rebind the slot — you must
# `systemd-cryptenroll --wipe-slot=tpm2 ...` and re-enroll.
#
# To remove TPM key (e.g. before returning device for repair):
#   sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/disk/by-partlabel/luks
#
# To re-enroll after PCR breach (e.g. after firmware update):
#   sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/disk/by-partlabel/luks
#   sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=2+7+15 /dev/disk/by-partlabel/luks
{
  # Required: systemd initrd handles TPM2 unlock in initrd stage
  boot.initrd.systemd.enable = true;

  # Tell the systemd crypttab entry to try TPM2 first, fall back to passphrase
  boot.initrd.luks.devices."cryptroot".crypttabExtraOpts = [
    "tpm2-device=auto"
    "tpm2-pcrs=2+7+15"
  ];

  # TPM2 userspace tools
  security.tpm2 = {
    enable              = true;
    pkcs11.enable       = true;
    tctiEnvironment.enable = true;
  };

  # systemd-cryptenroll is part of systemd — already available.
  # tpm2-tools for low-level TPM inspection if needed.
  environment.systemPackages = with pkgs; [
    tpm2-tools
  ];
}
