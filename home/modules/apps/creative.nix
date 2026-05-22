{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Raster image editing
    gimp

    # Vector graphics
    inkscape

    # RAW photo processing
    darktable

    # Office suite
    libreoffice-fresh

    # Email client
    thunderbird
  ];
}
