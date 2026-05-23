#!/usr/bin/env bash
# wal-sync — single-command palette regeneration.
#
# Drives pywal from a wallpaper, then templates the generated colors into
# every app that should follow the wallpaper. Today: kitty.
# Add templates under scripts/templates/ as you decide other apps should
# follow the wallpaper too.
#
# This is OPT-IN. The Compline palette in dotfiles/noctalia/colorschemes/
# remains the default; this only writes to files that explicitly accept
# wal-generated colors (see kitty/current-theme.conf).
#
# Usage:
#   ./scripts/wal-sync.sh ~/Pictures/Wallpapers/something.jpg
#   ./scripts/wal-sync.sh                 # uses pywal's last wallpaper

set -euo pipefail

WALL="${1:-}"
WAL_DIR="$HOME/.cache/wal"
COLORS_JSON="$WAL_DIR/colors.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/templates"

# Run pywal (or re-use last run if no arg)
if [[ -n "$WALL" ]]; then
  [[ -f "$WALL" ]] || { echo "wallpaper not found: $WALL" >&2; exit 1; }
  wal -i "$WALL" -n -q   # -n: no wallpaper set (Noctalia owns that), -q: quiet
fi

[[ -f "$COLORS_JSON" ]] || { echo "$COLORS_JSON missing — run pywal once first" >&2; exit 1; }

# Pull colors with jq into shell vars: color0..color15, background, foreground, cursor
eval "$(jq -r '
  .special as $sp | .colors as $c |
  "background=\"\($sp.background)\"",
  "foreground=\"\($sp.foreground)\"",
  "cursor=\"\($sp.cursor)\"",
  (range(0;16) | "color\(.)=\"\($c["color\(.)"])\"")
  | join("\n")
' "$COLORS_JSON")"

render() {
  local tmpl="$1"
  local out="$2"
  # envsubst keeps any other $-token untouched (we only export wal vars below)
  envsubst <"$tmpl" >"$out"
  echo "  -> $out"
}

export background foreground cursor \
       color0 color1 color2 color3 color4 color5 color6 color7 \
       color8 color9 color10 color11 color12 color13 color14 color15

echo "wal-sync: regenerating themes from $COLORS_JSON"

# ── kitty ──────────────────────────────────────────────────────────────
render "$TEMPLATE_DIR/kitty-wal.conf" "$HOME/.config/kitty/current-theme.conf"
# Live reload kitty (no restart needed if `include current-theme.conf` is in kitty.conf)
pkill -SIGUSR1 kitty 2>/dev/null || true

# Add more here as you template them:
#   render "$TEMPLATE_DIR/zathura-wal" "$HOME/.config/zathura/wal-colors"
#   render "$TEMPLATE_DIR/starship-wal.toml" "$HOME/.config/starship.wal.toml"
#   render "$TEMPLATE_DIR/hyprlock-wal.conf" "$HOME/.config/hypr/hyprlock-wal.conf"
#   render "$TEMPLATE_DIR/yazi-wal.toml" "$HOME/.config/yazi/flavors/wal.yazi/flavor.toml"
#   render "$TEMPLATE_DIR/noctalia-wal.json" "$HOME/.config/noctalia/colorschemes/Wal/Wal.json"

echo "wal-sync: done"
