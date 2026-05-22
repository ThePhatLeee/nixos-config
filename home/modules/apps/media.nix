{ pkgs, ... }:

{
  home.packages = with pkgs; [
    mpv
    imv
    pear-desktop        # YouTube Music desktop app (Electron wrapper, supports account login)
    easyeffects         # PipeWire DSP: EQ, compressor, reverb — Dolby Atmos equivalent on Linux
    lsp-plugins-lv2     # High-quality LV2 plugins for EasyEffects (parametric EQ, compressor, limiter)
    helvum              # PipeWire patchbay — visual routing, useful for Z407 sub management
  ];
}
