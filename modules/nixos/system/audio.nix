{ config, lib, pkgs, ... }:

{
  # Use pipewire — the modern audio stack for Wayland
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;

    extraConfig.pipewire."92-low-latency" = {
      context.properties = {
        default.clock.rate        = 48000;
        default.clock.quantum     = 512;
        default.clock.min-quantum = 32;
        default.clock.max-quantum = 8192;
      };
    };
  };
}
