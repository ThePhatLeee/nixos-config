{ config, lib, pkgs, ... }:

{
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
