{ pkgs, ... }:

{
  home.packages = with pkgs; [
    yazi     # → dotfiles/yazi/
    zathura  # → dotfiles/zathura/
  ];
}
