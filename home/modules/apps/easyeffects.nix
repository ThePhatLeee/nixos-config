{ pkgs, ... }:

let
  switchScript = pkgs.writeShellScript "ee-switch" ''
    PROFILES="$HOME/.config/easyeffects/profiles"
    DB="$HOME/.config/easyeffects/db"

    switch() {
      cp -f "$PROFILES/$1"/*rc "$DB"/
      systemctl --user restart easyeffects.service 2>/dev/null || true
    }

    case "$1" in
      *pci*1f.3*)          switch xps-internal   ;;
      *10_94_97_11_5D_1E*) switch z407            ;;
      # Uncomment and fill MAC once Pixel Buds Pro are paired:
      # *XX_XX_XX_XX_XX_XX*) switch pixel-buds-pro ;;
      *)                   switch xps-internal   ;;
    esac
  '';

  watchScript = pkgs.writeShellScript "ee-watch" ''
    pactl subscribe 2>/dev/null \
      | grep --line-buffered "change.*sink" \
      | while IFS= read -r _; do
          sink=$(pactl get-default-sink 2>/dev/null)
          [[ -n "$sink" ]] && ${switchScript} "$sink"
        done
  '';
in
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
      ExecStart  = "${watchScript}";
      Restart    = "on-failure";
      RestartSec = "3";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
