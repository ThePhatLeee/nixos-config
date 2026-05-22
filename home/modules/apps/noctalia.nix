{ inputs, ... }:

# Noctalia — Wayland desktop shell (bar, launcher, notifications, lock screen)
# Built on Quickshell. Config lives in dotfiles/noctalia/settings.json.
# settings intentionally unset — HM does NOT write settings.json,
# leaving the dotfiles symlink in full control.
# Custom colorschemes go in dotfiles/noctalia/colorschemes/<Name>/<Name>.json —
# Noctalia scans that directory alongside its built-ins.
# Docs: https://docs.noctalia.dev/v4/getting-started/nixos/
{
  imports = [ inputs.noctalia.homeModules.default ];
  programs.noctalia-shell.enable = true;
}
