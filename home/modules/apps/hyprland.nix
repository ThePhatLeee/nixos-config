{ pkgs, ... }:

# Hyprland user-level packages and cursor env vars.
# Session is started by system-level programs.hyprland (withUWSM).
# Config lives entirely in dotfiles/hypr/ via the dotfiles symlink.
#
# NOTE: hypridle + hyprpolkitagent removed — Noctalia v4 owns idle
# (ext-idle-notify-v1) and polkit (via the polkit-agent plugin).
{
  home.packages = with pkgs; [
    hyprcursor
    hyprpicker
    hyprshot
    kanshi
  ];

  home.sessionVariables = {
    HYPRCURSOR_THEME = "rose-pine-hyprcursor";
    HYPRCURSOR_SIZE  = "24";
    XCURSOR_THEME    = "rose-pine-hyprcursor";
    XCURSOR_SIZE     = "24";
  };

  systemd.user.services.kanshi = {
    Unit = {
      Description = "Kanshi display configuration";
      After       = [ "graphical-session.target" ];
      PartOf      = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.kanshi}/bin/kanshi";
      Restart    = "on-failure";
      RestartSec = 3;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
