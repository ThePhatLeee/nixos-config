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
      extraArgs = "--keep-since 7d --keep 5";
    };
  };

  environment.systemPackages = with pkgs; [
    # ── Run without installing ─────────────────────────────────────────
    # Usage: , <command>   e.g.  , cowsay hello
    comma

    # ── Build output visualizer ────────────────────────────────────────
    # Used automatically by nh; also usable as: nom build .#
    nix-output-monitor

    # ── Generation diff ────────────────────────────────────────────────
    # Shows what packages changed between two NixOS generations
    # Usage: nvd diff /run/current-system result
    nvd

    # ── Dependency tree viewer ────────────────────────────────────────
    # Usage: nix-tree  (interactive)  or  nix-tree /nix/store/...
    nix-tree

    # ── Nix file linter ───────────────────────────────────────────────
    # Usage: statix check .    statix fix .
    statix

    # ── Dead code remover ─────────────────────────────────────────────
    # Usage: deadnix -e file.nix    deadnix -e .
    deadnix

    # ── Nix formatter ─────────────────────────────────────────────────
    # Usage: alejandra .    (opinionated, fast)
    alejandra

    # ── Docs search ───────────────────────────────────────────────────
    # Usage: manix <term>    e.g.  manix "mkShell"
    manix

    # ── Generate nix fetcher expressions from URLs ────────────────────
    # Usage: nurl https://github.com/owner/repo
    nurl

    # ── Scaffold nix packages from scratch ───────────────────────────
    # Usage: nix-init
    nix-init
  ];
}
