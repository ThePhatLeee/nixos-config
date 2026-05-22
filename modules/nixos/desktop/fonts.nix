{ config, lib, pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      # Nerd Fonts — icons + programming
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.noto

      # UI / system fonts
      inter
      roboto
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji

      # Monospace
      jetbrains-mono
      fira-code
      fira-code-symbols
    ];

    fontconfig = {
      defaultFonts = {
        serif     = [ "Noto Serif" ];
        sansSerif = [ "Inter" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
        emoji     = [ "Noto Color Emoji" ];
      };
    };
  };
}
