{ pkgs, ... }:

{
  home.packages = with pkgs; [
    vscode-fhs    # FHS wrapper — native extension binaries work on NixOS
    gh            # GitHub CLI — extensions, PRs, auth
  ];
}
