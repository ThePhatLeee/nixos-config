{ ... }:
{
  services.syncthing = {
    enable = true;
    # Web UI: http://localhost:8384
    # Sync ~/Documents (Obsidian vault) and ~/nixos-config
  };
}
