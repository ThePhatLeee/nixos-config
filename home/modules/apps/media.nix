{ pkgs, ... }:

{
  home.packages = with pkgs; [
    mpv
    imv
    pear-desktop    # YouTube Music desktop app (Electron wrapper, supports account login)
  ];
}
