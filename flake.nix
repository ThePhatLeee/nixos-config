{
  description = "phatle's NixOS — flake, home-manager, modular";

  inputs = {
    # Switch to nixos-26.05 + home-manager/release-26.05 after May 30th
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Noctalia — Wayland desktop shell (bar, notifications, dock, widgets)
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware-specific NixOS modules (Dell XPS 15 9510 + NVIDIA)
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Pre-built nix-index database — replaces slow local index build for comma
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secure Boot — replaces systemd-boot, signs bootloader + kernel
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets management — sops-encrypted files, decrypted at activation
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, noctalia, nixos-hardware, nix-index-database, lanzaboote, sops-nix, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs   = nixpkgs.legacyPackages.${system};
  in {
    # `nix fmt` formats the whole tree with alejandra.
    formatter.${system} = pkgs.alejandra;

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/nixos/default.nix
        lanzaboote.nixosModules.lanzaboote
        sops-nix.nixosModules.sops

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs       = true;
          home-manager.useUserPackages     = true;
          home-manager.extraSpecialArgs    = { inherit inputs; };
          home-manager.backupFileExtension = "bak";
          home-manager.sharedModules       = [ sops-nix.homeManagerModules.sops ];
          home-manager.users.phatle        = import ./home/phatle/default.nix;
        }
      ];
    };
  };
}
