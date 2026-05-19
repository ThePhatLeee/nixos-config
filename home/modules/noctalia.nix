{ config, lib, pkgs, inputs, ... }:

# Noctalia — Wayland desktop shell (bar, notifications, dock, widgets)
# Built on Quickshell. HM module handles the systemd user service.
# Docs: https://docs.noctalia.dev/v4/getting-started/nixos/

{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia-shell = {
    enable = true;
    # settings default to upstream settings-default.json — override here as needed
    # Full option reference: check ~/.config/noctalia/settings-default.json after first run
    settings = {
      bar = {
        position = "top";
        height   = 36;
      };
      dock = {
        enable    = true;
        position  = "bottom";
        icon_size = 48;
      };
      notifications = {
        position = "top-right";
        timeout  = 5000;
      };
    };
  };
}
