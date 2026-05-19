{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # File management
    nautilus
    file-roller

    # Bluetooth GUI
    blueman

    # Media
    mpv
    imv

    # Utilities
    btop
    fastfetch
    ripgrep
    fd
    jq
    unzip
    tree
    claude-code
    hyprpolkitagent  # polkit agent for privilege dialogs
  ];
}
