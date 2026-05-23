#!/usr/bin/env bash
PROFILES="$HOME/.config/easyeffects/profiles"
DB="$HOME/.config/easyeffects/db"

switch() {
  cp -f "$PROFILES/$1"/*rc "$DB"/
  systemctl --user restart easyeffects.service 2>/dev/null || true
}

case "$1" in
  *pci*1f.3*)          switch xps-internal   ;;
  *10_94_97_11_5D_1E*) switch z407            ;;
  *B8_7B_D4_07_E8_37*) switch pixel-buds-pro ;;
  *)                   switch xps-internal   ;;
esac
