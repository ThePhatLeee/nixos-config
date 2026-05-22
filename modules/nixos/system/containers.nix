{ ... }:
{
  virtualisation.podman = {
    enable       = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
    autoPrune = {
      enable = true;
      dates  = "weekly";
    };
  };

  # Search registries in order — prefer ghcr/quay when image names are unambiguous
  virtualisation.containers.registries.search = [
    "docker.io"
    "ghcr.io"
    "quay.io"
  ];
}
