{ pkgs, ... }:
{
  services.snapper.configs = {
    root = {
      SUBVOLUME    = "/";
      ALLOW_USERS  = [ "phatle" ];
      TIMELINE_CREATE  = true;
      TIMELINE_CLEANUP = true;
      TIMELINE_LIMIT_HOURLY  = 0;
      TIMELINE_LIMIT_DAILY   = 7;
      TIMELINE_LIMIT_WEEKLY  = 4;
      TIMELINE_LIMIT_MONTHLY = 3;
      TIMELINE_LIMIT_YEARLY  = 0;
    };
    home = {
      SUBVOLUME    = "/home";
      ALLOW_USERS  = [ "phatle" ];
      TIMELINE_CREATE  = true;
      TIMELINE_CLEANUP = true;
      TIMELINE_LIMIT_HOURLY  = 0;
      TIMELINE_LIMIT_DAILY   = 7;
      TIMELINE_LIMIT_WEEKLY  = 4;
      TIMELINE_LIMIT_MONTHLY = 3;
      TIMELINE_LIMIT_YEARLY  = 0;
    };
  };

  services.btrfs.autoScrub = {
    enable      = true;
    interval    = "monthly";
    fileSystems = [ "/" "/home" ];
  };

  # Periodic balance — prevents metadata fragmentation on single-disk BTRFS over time.
  # -dusage=50 -musage=50: only relocate chunks that are less than 50% full.
  systemd.services.btrfs-balance = {
    description = "BTRFS balance";
    serviceConfig = {
      Type                 = "oneshot";
      ExecStart            = "${pkgs.btrfs-progs}/bin/btrfs balance start -dusage=50 -musage=50 /";
      IOSchedulingClass    = "idle";
      CPUSchedulingPolicy  = "idle";
    };
  };

  systemd.timers.btrfs-balance = {
    wantedBy    = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "monthly";
      Persistent = true;
    };
  };

  environment.systemPackages = [ pkgs.btrfs-assistant ];
}
