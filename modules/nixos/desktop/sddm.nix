{ pkgs, ... }:

let
  theme = (pkgs.sddm-astronaut.override {
    themeConfig = {
      # ── Layout ────────────────────────────────────────────────────────
      ScreenWidth  = "3456";
      ScreenHeight = "2160";
      FormPosition = "center";
      Font         = "JetBrainsMono Nerd Font";
      FontSize     = "14";
      RoundCorners = "20";

      # ── Background ────────────────────────────────────────────────────
      Background      = "Backgrounds/sddm.jpg";
      CropBackground  = "true";
      DimBackground   = "0.3";

      # ── Blur ──────────────────────────────────────────────────────────
      PartialBlur = "true";
      BlurMax     = "48";
      Blur        = "2.0";

      # ── Compline palette ─────────────────────────────────────────────
      # mSurface=#1a1d21  mSurfaceVariant=#22262b  mPrimary=#b4bcc4
      # mOnSurface=#f0efeb  mOnSurfaceVariant=#e0dcd4  mOutline=#3d424a
      FormBackgroundColor  = "#1a1d21";
      BackgroundColor      = "#1a1d21";
      DimBackgroundColor   = "#0f1114";

      HeaderTextColor = "#f0efeb";
      DateTextColor   = "#e0dcd4";
      TimeTextColor   = "#f0efeb";

      LoginFieldBackgroundColor    = "#22262b";
      PasswordFieldBackgroundColor = "#22262b";
      LoginFieldTextColor          = "#f0efeb";
      PasswordFieldTextColor       = "#f0efeb";
      PlaceholderTextColor         = "#515761";

      LoginButtonBackgroundColor = "#b4bcc4";
      LoginButtonTextColor       = "#1a1d21";

      SystemButtonsIconsColor          = "#e0dcd4";
      SessionButtonTextColor           = "#e0dcd4";
      VirtualKeyboardButtonTextColor   = "#e0dcd4";

      DropdownTextColor                 = "#f0efeb";
      DropdownBackgroundColor           = "#1a1d21";
      DropdownSelectedBackgroundColor   = "#3d424a";

      HighlightTextColor       = "#b4bcc4";
      HighlightBackgroundColor = "#3d424a";
      HighlightBorderColor     = "#b4bcc4";

      HoverUserIconColor                   = "#b4bcc4";
      HoverPasswordIconColor               = "#b4bcc4";
      HoverSystemButtonsIconsColor         = "#b4bcc4";
      HoverSessionButtonTextColor          = "#b4bcc4";
      HoverVirtualKeyboardButtonTextColor  = "#b4bcc4";

      WarningColor = "#cdacac";

      # ── Behaviour ─────────────────────────────────────────────────────
      ForceLastUser        = "true";
      PasswordFocus        = "true";
      HideCompletePassword = "true";
      HideVirtualKeyboard  = "true";
    };
  }).overrideAttrs (old: {
    # Bundle the wallpaper into the package — SDDM runs as system service,
    # can't read ~/Pictures. The Nix store path is readable by all users.
    postInstall = (old.postInstall or "") + ''
      cp ${../../../dotfiles/wallpapers/sddm.jpg} \
        $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/sddm.jpg
    '';
  });
in
{
  services.displayManager.sddm = {
    enable         = true;
    wayland.enable = true;
    theme          = "sddm-astronaut-theme";
    extraPackages  = [ theme ];
  };
}
