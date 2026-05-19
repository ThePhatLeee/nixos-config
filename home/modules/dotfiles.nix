{ config, ... }:

let
  link    = path: config.lib.file.mkOutOfStoreSymlink path;
  dotfiles = "${config.home.homeDirectory}/nixos-config/dotfiles";
in {
  # Symlink entire config directories straight from the repo.
  # Edit any file inside dotfiles/ and changes are live immediately — no rebuild.
  home.file = {
    ".config/hypr".source  = link "${dotfiles}/hypr";
    ".config/kitty".source = link "${dotfiles}/kitty";
    ".claude".source       = link "${dotfiles}/claude";
    # noctalia is managed by programs.noctalia-shell (HM module owns ~/.config/noctalia)
  };
}
