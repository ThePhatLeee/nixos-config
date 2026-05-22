{ config, lib, pkgs, ... }:

{
  # ── Zsh ───────────────────────────────────────────────────────────────
  # Plugins need HM to install them — everything else lives in dotfiles
  programs.zsh = {
    enable                    = true;
    dotDir                    = "${config.xdg.configHome}/zsh";   # XDG: ~/.config/zsh/
    autosuggestion.enable     = true;
    syntaxHighlighting.enable = true;
    history = {
      size       = 100000;
      save       = 100000;
      ignoreDups = true;
      share      = true;
    };
    # Custom config lives in dotfiles/zsh/extra.zsh — edit there, instant effect
    initContent = "source ${config.home.homeDirectory}/nixos-config/dotfiles/zsh/extra.zsh";
  };

  # ── Eza — adds ls/ll/la/lt aliases to .zshrc ─────────────────────────
  programs.eza = {
    enable               = true;
    enableZshIntegration = true;
    icons                = "auto";
    git                  = true;
    extraOptions         = [ "--group-directories-first" ];
  };

  # ── Fzf — adds CTRL+R / CTRL+T / ALT+C bindings to .zshrc ───────────
  programs.fzf = {
    enable               = true;
    enableZshIntegration = true;
  };

  # ── Direnv — adds eval hook to .zshrc, nix-direnv for dev shells ─────
  programs.direnv = {
    enable            = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # ── Tools — packages only, configs live in dotfiles/ ─────────────────
  programs.zellij.enable = true;

  home.packages = with pkgs; [
    starship
    zoxide
    atuin
    bat
  ];
}
