{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/nixos/disks.nix   # LUKS2 + BTRFS filesystems (post-LUKS install)
    ../../modules/nixos/boot.nix
    ../../modules/nixos/locale.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/bluetooth.nix
    ../../modules/nixos/hyprland.nix
    ../../modules/nixos/fonts.nix
    ../../modules/nixos/nix-settings.nix
    ../../modules/nixos/nix-tools.nix
    ../../modules/nixos/sddm.nix
    ../../modules/nixos/users.nix
  ];

  networking.hostName = "nixos";

  system.stateVersion = "25.11";
}
