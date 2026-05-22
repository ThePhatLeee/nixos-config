{ config, lib, pkgs, ... }:

{
  # ── nh ────────────────────────────────────────────────────────────────
  # Nix helper — replaces nixos-rebuild/home-manager with better UX:
  #   nh os switch     → rebuild + nvd diff + nom output
  #   nh os boot       → set next boot generation
  #   nh home switch   → home-manager switch
  #   nh search <pkg>  → search nixpkgs
  #   nh clean         → garbage collection
  programs.nh = {
    enable    = true;
    flake     = "/home/phatle/nixos-config";  # sets $FLAKE, used by all nh commands

    # Auto-clean old generations
    clean = {
      enable    = true;
      dates     = "weekly";
      extraArgs = "--keep-since 7d --keep 10";
    };
  };

  # comma and nix-index provided by nix-index-database HM module (pre-built daily index)
  environment.systemPackages = with pkgs; [
    nix-output-monitor  # nom build .#  (used automatically by nh)
    nvd                 # nvd diff /run/current-system result
    nix-tree            # nix-tree /nix/store/...
    statix              # statix check/fix .
    deadnix             # deadnix -e .
    alejandra           # alejandra .
    manix               # manix "mkShell"
    nurl                # nurl https://github.com/owner/repo
    nix-init            # scaffold new nix packages
  ];

  # Man page indexing — enables man -k, apropos, and whatis across all installed pages
  documentation.man.enable = true;
}
