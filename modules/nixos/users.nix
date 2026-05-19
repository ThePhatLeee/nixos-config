{ config, lib, pkgs, ... }:

{
  # Root: password set during install (nixos-install prompts).
  # Locked from SSH; usable only at physical console for recovery.
  services.openssh.settings.PermitRootLogin = lib.mkDefault "no";

  users.users.phatle = {
    isNormalUser = true;
    description = "phatle";
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
