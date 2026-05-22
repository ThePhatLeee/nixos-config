{ pkgs, ... }:
{
  home.packages = with pkgs; [
    distrobox
    podman-compose
    podman-desktop
  ];
}
