{ config, lib, pkgs, ... }:

{
  programs.hyprland = {
    enable          = true;
    withUWSM        = true;
    xwayland.enable = true;
  };

  # XDG portals — file picker, screen share, screenshots
  xdg.portal = {
    enable       = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland    # screen share / capture in Hyprland
    ];
  };

  security.polkit.enable = true;

  # dconf — required by GTK/GNOME apps (darktable, gimp, libreoffice, nautilus)
  programs.dconf.enable = true;

  # Secrets / keyring — browser passwords, SSH keys, wallet
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  # Wayland + HiDPI environment
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
    cliphist       # clipboard history backend for Noctalia
    wtype          # virtual keyboard — required by Noctalia appLauncher.autoPasteClipboard
                   # Without it, the autoPaste toggle is greyed out in the Noctalia GUI
                   # (ProgramCheckerService.wtypeAvailable gate, per ClipboardSubTab.qml)
    xdg-utils
    libnotify      # notify-send — scripts, earlyoom desktop alerts, custom notifications
    man-pages       # Linux syscall man pages (man 2 open, man 2 mmap, ...)
    man-pages-posix # POSIX API man pages (man 3 malloc, man 3 pthread_create, ...)
  ];

  programs.firefox.enable = true;
}
