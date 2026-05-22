{ config, lib, pkgs, ... }:

# Laptop power management — TLP, firmware updates, battery info.
# thermald is handled by nixos-hardware/dell-xps-15-9510 (mkDefault true).
# TLP conflicts with power-profiles-daemon; the latter is disabled here.
{
  services.power-profiles-daemon.enable = false;

  services.tlp = {
    enable = true;
    settings = {
      # ── CPU ──────────────────────────────────────────────────────────
      CPU_SCALING_GOVERNOR_ON_AC  = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC  = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      # ── Battery health (Dell XPS 15 9510) ────────────────────────────
      # Charge between 20–80 % to reduce long-term capacity loss.
      # Disable to allow full charge: set both to 0.
      START_CHARGE_THRESH_BAT0 = 20;
      STOP_CHARGE_THRESH_BAT0  = 80;

      # ── PCI runtime PM ────────────────────────────────────────────────
      # "auto" lets the kernel (and NVIDIA fine-grained PM) power-gate
      # idle PCI devices on battery; "on" keeps them powered on AC.
      RUNTIME_PM_ON_BAT = "auto";
      RUNTIME_PM_ON_AC  = "on";

      # ── PCIe ASPM ────────────────────────────────────────────────────
      PCIE_ASPM_ON_BAT = "powersave";

      # ── WiFi ─────────────────────────────────────────────────────────
      WIFI_PWR_ON_BAT = "on";
      WIFI_PWR_ON_AC  = "off";

      # ── CPU turbo + platform profile ─────────────────────────────────
      CPU_BOOST_ON_BAT = 0;
      PLATFORM_PROFILE_ON_AC  = "performance";
      PLATFORM_PROFILE_ON_BAT = "balanced";

      # ── USB autosuspend ───────────────────────────────────────────────
      USB_AUTOSUSPEND_ON_BAT = 1;

      # ── SATA link power ───────────────────────────────────────────────
      SATA_LINKPWR_ON_BAT = "med_power_with_dipm";

      # ── Audio power saving ────────────────────────────────────────────
      SOUND_POWER_SAVE_ON_BAT      = 1;
      SOUND_POWER_SAVE_CONTROLLER  = "Y";
    };
  };

  # IRQ distribution across cores — improves throughput under load
  services.irqbalance.enable = true;

  # UEFI + device firmware updates via fwupdmgr
  services.fwupd.enable = true;

  # Battery status — required by desktop shell / status bars
  services.upower.enable = true;

  # Redistributable firmware + Intel microcode (enables the mkDefault in hw config)
  hardware.enableRedistributableFirmware = true;
}
