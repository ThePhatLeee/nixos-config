{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ../modules/dotfiles.nix
    ../modules/hypr.nix
    ../modules/noctalia.nix
    ../modules/packages.nix
    ../modules/apps/kitty.nix
  ];

  home.username    = "phatle";
  home.homeDirectory = "/home/phatle";
  home.stateVersion  = "25.11";

  programs.home-manager.enable = true;

  # Cursor — hyprcursor theme
  home.pointerCursor = {
    gtk.enable = true;
    package    = pkgs.rose-pine-hyprcursor;
    name       = "rose-pine-hyprcursor";
    size       = 24;
  };

  gtk = {
    enable = true;
    theme = {
      name    = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name    = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk4.theme = null; # adopt new default (no forced GTK4 theme override)
  };

  xdg.enable = true;
  xdg.userDirs = {
    enable               = true;
    createDirectories    = true;
    setSessionVariables  = true;
  };
}
