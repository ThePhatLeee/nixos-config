{ pkgs, ... }:

let
  mac-style-plymouth = pkgs.stdenvNoCC.mkDerivation {
    pname   = "s4rchiso-mac-style-plymouth";
    version = "unstable-2026-05-13";

    src = pkgs.fetchFromGitHub {
      owner = "SergioRibera";
      repo  = "s4rchiso-plymouth-theme";
      rev   = "2f782f4b68ce1c00cef3fde6970d7b4241bb97d4";
      hash  = "sha256-bjtQvzupAFX5AYAIyBXSFgWhaG4nP4TvgKDoKyUhZ4U=";
    };

    installPhase = ''
      mkdir -p $out/share/plymouth/themes/mac-style
      cp -r src/mac-style $out/share/plymouth/themes/

      # Fix image path placeholder
      substituteInPlace $out/share/plymouth/themes/mac-style/mac-style.plymouth \
        --replace '@IMAGES@' "$out/share/plymouth/themes/mac-style/images/"

      # Compline palette: surface=#1a1d21  outline=#3d424a  primary=#b4bcc4
      substituteInPlace $out/share/plymouth/themes/mac-style/mac-style.plymouth \
        --replace 'BackgroundStartColor=0x000000' 'BackgroundStartColor=0x1a1d21' \
        --replace 'BackgroundEndColor=0x000000'   'BackgroundEndColor=0x1a1d21'   \
        --replace 'ProgressBarBackgroundColor=0x333333' 'ProgressBarBackgroundColor=0x3d424a' \
        --replace 'ProgressBarForegroundColor=0xffffff' 'ProgressBarForegroundColor=0xb4bcc4'
    '';
  };
in
{
  boot.plymouth = {
    enable        = true;
    theme         = "mac-style";
    themePackages = [ mac-style-plymouth ];
  };
}
