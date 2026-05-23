{ config, ... }:

let
  link    = path: config.lib.file.mkOutOfStoreSymlink path;
  dotfiles = "${config.home.homeDirectory}/nixos-config/dotfiles";
in {
  # Symlink entire config directories straight from the repo.
  # Edit any file inside dotfiles/ and changes are live immediately — no rebuild.
  home.file = {
    ".config/hypr".source          = link "${dotfiles}/hypr";
    ".config/kitty".source         = link "${dotfiles}/kitty";
    ".config/zellij".source                  = link "${dotfiles}/zellij";
    ".config/starship.toml".source           = link "${dotfiles}/starship/starship.toml";
    ".config/noctalia".source                = link "${dotfiles}/noctalia";
    ".config/yazi".source                    = link "${dotfiles}/yazi";
    ".config/zathura".source                 = link "${dotfiles}/zathura";
    ".config/lazygit".source                 = link "${dotfiles}/lazygit";
    ".config/btop".source                    = link "${dotfiles}/btop";
    ".config/kanshi".source                  = link "${dotfiles}/kanshi";
    ".config/easyeffects".source             = link "${dotfiles}/easyeffects";
    ".claude".source                         = link "${dotfiles}/claude";
    ".vscode-oss/argv.json".source           = link "${dotfiles}/vscode/argv.json";
  };
}
