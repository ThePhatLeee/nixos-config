{ config, lib, pkgs, ... }:

{
  networking.networkmanager.enable = true;

  # Needed for Hyprland portals and some wayland apps
  networking.firewall.enable = true;
}
