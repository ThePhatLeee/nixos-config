{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gnupg
    age
    gopass
  ];

  services.gpg-agent = {
    enable           = true;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-gnome3;
    defaultCacheTtl  = 3600;
    maxCacheTtl      = 86400;
  };
}
