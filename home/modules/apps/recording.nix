{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (wrapOBS {
      plugins = with obs-studio-plugins; [
        obs-pipewire-audio-capture
        obs-backgroundremoval
        wlrobs
      ];
    })
    davinci-resolve
    v4l-utils
  ];
}
