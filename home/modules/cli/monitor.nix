{ pkgs, ... }:

{
  home.packages = with pkgs; [
    btop   # system monitor
    dust   # better du
    duf    # better df
  ];
}
