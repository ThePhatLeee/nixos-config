#!/usr/bin/env bash
pactl subscribe 2>/dev/null \
  | grep --line-buffered "change.*sink" \
  | while IFS= read -r _; do
      sink=$(pactl get-default-sink 2>/dev/null)
      [[ -n "$sink" ]] && "$HOME/.config/easyeffects/ee-switch.sh" "$sink"
    done
