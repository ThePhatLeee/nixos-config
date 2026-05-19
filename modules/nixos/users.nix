{ config, lib, pkgs, ... }:

{
  # Root: initialHashedPassword = "" means passwordless root at the physical
  # console — required for emergency mode recovery (sulogin). SSH root login
  # remains blocked. Change with: sudo passwd root
  users.users.root.initialHashedPassword = "";
  services.openssh.settings.PermitRootLogin = lib.mkDefault "no";

  users.users.phatle = {
    isNormalUser = true;
    description  = "phatle";
    # Temporary first-login password — change immediately with: passwd
    initialPassword = "nixos";
    extraGroups = [
      "wheel"           # sudo
      "networkmanager"  # nmcli/nmtui without sudo
      "video"           # brightness control
      "audio"           # audio devices
      "input"           # input devices
    ];
    shell = pkgs.bash;
  };
}
