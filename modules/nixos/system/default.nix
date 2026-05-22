{ ... }:

{
  imports = [
    ./audio.nix
    ./bluetooth.nix
    ./boot.nix
    ./containers.nix
    ./disks.nix
    ./locale.nix
    ./networking.nix
    ./security.nix
    ./snapshots.nix
    ./ssh.nix
    ./tpm.nix
    ./usbguard.nix
    ./users.nix
    ./virtualization.nix
    ./vpn.nix
    ./sops.nix
  ];
}
