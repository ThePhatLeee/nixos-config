{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # generates color schemes from wallpaper → ~/.cache/wal/colors.json
    # usage: wal -i /path/to/wallpaper.jpg && pywalfox update
    pywal
    # native messaging daemon — after first install run: pywalfox install
    pywalfox-native
  ];
}
