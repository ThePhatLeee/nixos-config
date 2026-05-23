{ config, ... }:

{
  services.easyeffects.enable = true;

  systemd.user.services.easyeffects-autoswitch = {
    Unit = {
      Description = "EasyEffects auto profile switcher";
      After       = [ "easyeffects.service" "pipewire-pulse.service" ];
      Requires    = [ "easyeffects.service" ];
      PartOf      = [ "graphical-session.target" ];
    };
    Service = {
      Type       = "simple";
      ExecStart  = "${config.home.homeDirectory}/.config/easyeffects/ee-watch.sh";
      Restart    = "on-failure";
      RestartSec = "3";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
