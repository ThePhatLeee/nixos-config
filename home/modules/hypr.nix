{ config, lib, pkgs, ... }:

# Hyprland user-level packages and env vars.
# Session is handled by system-level programs.hyprland (withUWSM).
# Config is handled entirely by the dotfiles symlink in dotfiles.nix.
# No wayland.windowManager.hyprland here — that would generate files
# that conflict with the ~/.config/hypr symlink.

{
  home.packages = with pkgs; [
    hyprcursor
    hyprlock
    hypridle
    hyprpaper
    hyprsunset
    hyprpolkitagent
    hyprpicker
    hyprshot
  ];

  home.sessionVariables = {
    HYPRCURSOR_THEME = "rose-pine-hyprcursor";
    HYPRCURSOR_SIZE  = "24";
    XCURSOR_THEME    = "rose-pine-hyprcursor";
    XCURSOR_SIZE     = "24";
  };
}
