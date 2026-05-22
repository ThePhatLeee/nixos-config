{ pkgs, ... }:

{
  home.packages = with pkgs; [
    mpv
    imv
    pear-desktop        # YouTube Music desktop app (Electron wrapper, supports account login)
    easyeffects         # PipeWire DSP: EQ, compressor, reverb — Dolby Atmos equivalent on Linux
    lsp-plugins         # High-quality LV2 plugins for EasyEffects (parametric EQ, compressor, limiter)
    crosspipe           # PipeWire patchbay — visual routing, useful for Z407 sub management
  ];
}
