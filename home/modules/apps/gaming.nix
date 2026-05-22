{ pkgs, ... }:

{
  home.packages = with pkgs; [
    heroic
    lutris
  ];
}
