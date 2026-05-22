{ config, lib, pkgs, ... }:

# Dell XPS 15 9510 — hardware extras not covered by nixos-hardware module
{
  # ── Fingerprint reader ────────────────────────────────────────────────
  # Enroll after enabling: fprintd-enroll -f right-index-finger
  # The XPS 15 9510 ships with a Goodix in-display sensor; if plain fprintd
  # fails to detect it, uncomment the tod block below and rebuild.
  services.fprintd.enable = true;
  # services.fprintd.tod = {
  #   enable = true;
  #   driver = pkgs.libfprint-2-tod1-goodix;
  # };

  # ── Thunderbolt ───────────────────────────────────────────────────────
  # bolt authorises/deauthorises Thunderbolt devices (security levels)
  services.hardware.bolt.enable = true;

  # ── Color management ──────────────────────────────────────────────────
  # colord manages ICC profiles — used by darktable, GIMP, and the display
  services.colord.enable = true;
}
