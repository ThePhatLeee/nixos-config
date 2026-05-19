{ config, lib, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Always run the latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Silent boot — clean tty on startup
  boot.consoleLogLevel = 3;
  boot.kernelParams = [ "quiet" "splash" "loglevel=3" ];
}
