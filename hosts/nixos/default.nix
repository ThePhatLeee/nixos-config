{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    # Dell XPS 15 9510 — base laptop (WiFi fix, thermald, TLP, Intel iGPU, SSD TRIM)
    inputs.nixos-hardware.nixosModules.dell-xps-15-9510
    # Dell XPS 15 9510 — NVIDIA PRIME offload + open Ampere drivers
    inputs.nixos-hardware.nixosModules.dell-xps-15-9510-nvidia

    ../../modules/nixos/system
    ../../modules/nixos/hardware
    ../../modules/nixos/desktop
    ../../modules/nixos/nix
  ];

  networking.hostName = "nixos";

  programs.zsh.enable = true;

  system.stateVersion = "25.11";
}
