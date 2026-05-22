{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nautilus
    file-roller
  ];
}
