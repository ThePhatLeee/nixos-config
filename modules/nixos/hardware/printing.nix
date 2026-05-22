{ config, lib, pkgs, ... }:

{
  # ── CUPS ──────────────────────────────────────────────────────────────
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint      # broad coverage: Epson, Canon, HP, etc.
      gutenprintBin   # binary-only supplement drivers
      hplip           # HP printers + scanner
    ];
  };

  # ── Avahi (mDNS) ──────────────────────────────────────────────────────
  # Auto-discovers network printers; also resolves .local hostnames
  services.avahi = {
    enable      = true;
    nssmdns4    = true;       # .local resolution in /etc/nsswitch.conf
    openFirewall = true;      # UDP 5353
  };

  # ── Scanner support (SANE) ────────────────────────────────────────────
  hardware.sane = {
    enable        = true;
    extraBackends = with pkgs; [
      sane-airscan    # driverless: AirScan / eSCL / WSD network scanners
    ];
  };

  # scanner group: SANE, lp group: CUPS administration
  users.users.phatle.extraGroups = [ "scanner" "lp" ];
}
