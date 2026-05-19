{ pkgs, ... }:

# Config symlinked via dotfiles.nix: ~/.config/kitty → dotfiles/kitty/

{ home.packages = [ pkgs.kitty ]; }
