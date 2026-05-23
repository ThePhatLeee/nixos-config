{ pkgs, ... }:

let
  theme = pkgs.stdenvNoCC.mkDerivation {
    name = "sddm-compline-theme";
    src  = ../../../dotfiles/sddm;
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      install -d $out/share/sddm/themes/sddm-astronaut-theme
      cp -r . $out/share/sddm/themes/sddm-astronaut-theme/
      runHook postInstall
    '';
  };
in
{
  services.displayManager.sddm = {
    enable         = true;
    wayland.enable = true;
    theme          = "sddm-astronaut-theme";
    extraPackages  = with pkgs.kdePackages; [
      theme
      qtsvg
      qtmultimedia
      qtvirtualkeyboard
    ];
  };
}
