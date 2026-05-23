{ pkgs, ... }:

{
  home.packages = with pkgs; [
    pywal
    pywalfox-native
    matugen
  ];
}
