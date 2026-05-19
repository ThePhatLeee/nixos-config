{ config, lib, pkgs, ... }:

{
  programs.hyprland = {
    enable          = true;
    withUWSM        = true;
    xwayland.enable = true;
  };

  # XDG portals — file picker, screen share, screenshots
  xdg.portal = {
    enable      = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  security.polkit.enable = true;

  # Wayland environment
  environment.sessionVariables = {
    NIXOS_OZONE_WL              = "1";
    MOZ_ENABLE_WAYLAND          = "1";
    SDL_VIDEODRIVER             = "wayland";
    GDK_BACKEND                 = "wayland,x11";
    QT_QPA_PLATFORM             = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    brightnessctl
    playerctl
    grim           # screenshot backend
    slurp          # region picker
    wl-clipboard   # wl-copy / wl-paste
    cliphist       # clipboard history
    xdg-utils
    networkmanagerapplet
  ];

  programs.firefox.enable = true;
}
