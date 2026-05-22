{ ... }:

# nix-index-database provides a pre-built daily index — no local build needed.
# comma uses it automatically: , cowsay hello  (installs + runs without nixos-rebuild)
{
  programs.nix-index-database.comma.enable = true;
}
