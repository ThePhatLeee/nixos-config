{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nautilus
    file-roller
    trash-cli
  ];

  # Empty trash items older than 30 days — runs weekly
  systemd.user.services.trash-empty = {
    Unit.Description = "Empty trash older than 30 days";
    Service = {
      Type       = "oneshot";
      ExecStart  = "${pkgs.trash-cli}/bin/trash-empty 30";
    };
  };

  systemd.user.timers.trash-empty = {
    Unit.Description = "Weekly trash cleanup";
    Timer = {
      OnCalendar = "weekly";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
