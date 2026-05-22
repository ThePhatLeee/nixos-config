{ config, lib, pkgs, ... }:

{
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;

    extraConfig.pipewire."10-clock" = {
      "context.properties" = {
        # 48 kHz default — matches internal DAC, HDMI, Bluetooth A2DP
        "default.clock.rate"          = 48000;
        # Allow native rates to avoid resampling: 44.1 kHz CDs, 96 kHz hi-res
        "default.clock.allowed-rates" = [ 44100 48000 88200 96000 ];
        # Soxr resampler at maximum quality when rate conversion IS needed
        "resample.quality"            = 15;
        # 512 frames @ 48kHz = ~10ms — good balance for music + system sounds
        "default.clock.quantum"       = 512;
        "default.clock.min-quantum"   = 32;
        "default.clock.max-quantum"   = 8192;
      };
    };

    # Bluetooth: prefer high-quality codecs in order, enable hw volume control
    wireplumber.extraConfig."10-bluez" = {
      "monitor.bluez.properties" = {
        "bluez5.codecs"          = "[ldac aptx_hd aptx aac celt_x celt sbc_xq sbc]";
        "bluez5.enable-hw-volume" = true;
        "bluez5.headset-roles"   = "[hsp_hs hsp_ag hfp_hf hfp_ag]";
        "bluez5.hfphsp-backend"  = "native";
        # A2DP sink always preferred over HSP/HFP for music
        "bluez5.a2dp.ldac.quality" = "auto";
      };
    };

    # XPS 15 internal speakers: raise priority so they stay default when headphones unplugged
    wireplumber.extraConfig."20-alsa-policy" = {
      "monitor.alsa.rules" = [
        {
          matches = [{ "node.name" = "alsa_output.pci-0000_00_1f.3.*"; }];
          actions.update-props = {
            "priority.session" = 1500;
            "node.description" = "XPS 15 Speakers";
          };
        }
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    alsa-utils      # amixer, aplay, arecord — low-level ALSA control
    pavucontrol     # PulseAudio volume control (works with pipewire-pulse)
  ];
}
