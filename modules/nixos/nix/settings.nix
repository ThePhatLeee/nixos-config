{ config, lib, pkgs, ... }:

{
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];

      substituters = [
        "https://cache.nixos.org"
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCUSeBo="
      ];

      auto-optimise-store  = true;
      max-jobs             = "auto";   # parallel derivations — use all cores
      cores                = 0;        # cores per derivation (0 = all available)
      keep-outputs              = true;   # keep build outputs for nix develop / debugging
      keep-derivations          = true;   # keep .drv files for debugging failed builds
      builders-use-substitutes  = true;   # remote builders pull from caches instead of building
    };

    # Nix daemon runs at lower priority so builds don't kill desktop responsiveness
    daemonCPUSchedPolicy = "batch";
    daemonIOSchedClass   = "idle";

    # Garbage collection is handled by programs.nh.clean in nix-tools.nix
  };

  nixpkgs.config.allowUnfree = true;

  # zram: compressed in-memory swap (primary, fast).
  # Swapfile on disk (/swap/swapfile) is the fallback + hibernation target.
  zramSwap = {
    enable    = true;
    algorithm = "zstd";
    memoryPercent = 50;   # up to 50% of RAM as compressed swap
  };
}
