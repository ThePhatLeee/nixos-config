{ config, lib, pkgs, ... }:

{
  # Root password is set during nixos-install (it always prompts).
  # With mutableUsers = true (default), that password persists across
  # nixos-rebuild switch — never gets reset by the flake.
  # SSH root login is blocked; root is only usable at the physical console.
  services.openssh.settings.PermitRootLogin = lib.mkDefault "no";

  users.users.phatle = {
    isNormalUser = true;
    description  = "phatle";
    # Temporary first-login password applied when the flake is first activated.
    # Change immediately after first login: passwd
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
