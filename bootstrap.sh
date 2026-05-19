#!/usr/bin/env bash
# Bootstrap: enable flakes in old config, then switch to the new flake config
set -e

echo "==> Step 1: Enable flakes in current /etc/nixos/configuration.nix"
if ! grep -q "experimental-features" /etc/nixos/configuration.nix; then
  sudo sed -i 's/nixpkgs.config.allowUnfree = true;/nixpkgs.config.allowUnfree = true;\n  nix.settings.experimental-features = [ "nix-command" "flakes" ];/' \
    /etc/nixos/configuration.nix
  echo "     Added flakes setting."
else
  echo "     Flakes already enabled, skipping."
fi

echo "==> Step 2: Rebuild with old config to activate flakes"
sudo nixos-rebuild switch

echo "==> Step 3: Initialize git in ~/nixos-config"
cd ~/nixos-config
git init
git add .
git commit -m "Initial modular NixOS + Hyprland + Noctalia config"

echo "==> Step 4: Switch to new flake config"
sudo nixos-rebuild switch --flake ~/nixos-config#nixos

echo ""
echo "Done! Your system is now running from ~/nixos-config."
echo ""
echo "Optional: symlink /etc/nixos to ~/nixos-config for convenience:"
echo "  sudo mv /etc/nixos /etc/nixos.bak"
echo "  sudo ln -s /home/phatle/nixos-config /etc/nixos"
echo ""
echo "Going forward, rebuild with:"
echo "  sudo nixos-rebuild switch --flake ~/nixos-config#nixos"
