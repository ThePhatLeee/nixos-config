{ config, lib, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Always run the latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Silent boot — clean tty on startup.
  # No "splash" here: Plymouth is not enabled, and "splash" without it blacks out
  # the framebuffer so the LUKS passphrase prompt never becomes visible.
  boot.consoleLogLevel = 3;
  boot.kernelParams = [ "quiet" "loglevel=3" ];
}
