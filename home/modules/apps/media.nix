{ pkgs, ... }:

{
  home.packages = with pkgs; [
    mpv
    imv
    pear-desktop        # YouTube Music desktop app (Electron wrapper, supports account login)
    lsp-plugins         # LV2 plugins loaded by EasyEffects (parametric EQ, compressor, limiter)
    crosspipe           # PipeWire patchbay — visual routing
  ];
}
