{ pkgs, ... }:

{
  programs.steam = {
    enable                   = true;
    remotePlay.openFirewall  = true;
    dedicatedServer.openFirewall = false;
    extraCompatPackages      = with pkgs; [ proton-ge-bin ];
  };

  programs.gamemode.enable = true;

  hardware.graphics = {
    enable    = true;
    enable32Bit = true;
  };
}
