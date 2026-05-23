{ ... }:

{
  services.graphical-desktop.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open = true;

    powerManagement = {
      enable      = true;
      finegrained = true;
    };

    dynamicBoost.enable = true;
  };
}
