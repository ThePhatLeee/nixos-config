{ config, lib, pkgs, ... }:

let
  sddmThemeFonts = pkgs.stdenvNoCC.mkDerivation {
    name = "sddm-theme-fonts";
    src  = ../../../dotfiles/sddm/Fonts;
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      install -d $out/share/fonts/sddm-theme
      find . -type f \( -name "*.ttf" -o -name "*.otf" \) -exec cp {} $out/share/fonts/sddm-theme/ \;
      runHook postInstall
    '';
  };
in

{
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      sddmThemeFonts
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
