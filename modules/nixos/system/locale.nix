{ config, lib, pkgs, ... }:

{
  time.timeZone = "Europe/Helsinki";

  i18n = {
    defaultLocale = "en_US.UTF-8";    # UI language — English
    extraLocaleSettings = {
      LC_ADDRESS        = "fi_FI.UTF-8";
      LC_IDENTIFICATION = "fi_FI.UTF-8";
      LC_MEASUREMENT    = "fi_FI.UTF-8";
      LC_MONETARY       = "fi_FI.UTF-8";
      LC_NAME           = "fi_FI.UTF-8";
      LC_NUMERIC        = "fi_FI.UTF-8";
      LC_PAPER          = "fi_FI.UTF-8";
      LC_TELEPHONE      = "fi_FI.UTF-8";
      LC_TIME           = "fi_FI.UTF-8";
    };
  };

  # TTY keyboard layout
  console = {
    keyMap = "fi";
    font   = "Lat2-Terminus16";
  };
}
