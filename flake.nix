{
  description = "phatle's NixOS — flake, home-manager, modular";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Noctalia — Wayland desktop shell (bar, notifications, dock, widgets)
    # Replaces waybar + notification daemons
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, noctalia, ... }@inputs:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/nixos/default.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs       = true;
          home-manager.useUserPackages   = true;
          home-manager.extraSpecialArgs  = { inherit inputs; };
          home-manager.backupFileExtension = "bak";
          home-manager.users.phatle      = import ./home/phatle/default.nix;
        }
      ];
    };
  };
}
