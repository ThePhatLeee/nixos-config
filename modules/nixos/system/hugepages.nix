{ config, lib, ... }:

# Static hugepages for KVM/QEMU. OFF by default — flip on when running
# heavy VMs (Kali for sustained work, Windows AD lab, anything > 4 GB RAM
# resident). When enabled, the configured amount is locked at boot and
# unavailable to the rest of the system, so leave disabled for normal
# day-to-day use.
#
# Enable in hosts/nixos/default.nix:
#   my.hugepages = {
#     enable = true;
#     pages  = 2048;   # 2048 × 2MB = 4 GB
#   };
let
  cfg = config.my.hugepages;
in
{
  options.my.hugepages = {
    enable = lib.mkEnableOption "static 2MB hugepages reserved at boot for KVM/QEMU";

    pages = lib.mkOption {
      type = lib.types.ints.positive;
      default = 2048;
      description = "Number of 2MB hugepages to reserve. 2048 = 4 GB.";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelParams = [
      "hugepagesz=2M"
      "hugepages=${toString cfg.pages}"
    ];

    boot.kernel.sysctl."vm.nr_hugepages" = cfg.pages;

    # Allow libvirtd's qemu user to lock huge pages
    security.pam.loginLimits = [
      { domain = "@kvm"; type = "soft"; item = "memlock"; value = "unlimited"; }
      { domain = "@kvm"; type = "hard"; item = "memlock"; value = "unlimited"; }
    ];

    # Nested virt for container-in-VM experiments (Kali running its own
    # containers, Windows running WSL2, etc.)
    boot.extraModprobeConfig = ''
      options kvm_intel nested=1
    '';
  };
}
