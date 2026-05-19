{ config, lib, pkgs, ... }:

{
  services.displayManager.sddm = {
    enable         = true;
    wayland.enable = true;  # SDDM Wayland backend
  };
}
