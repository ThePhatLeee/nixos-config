#!/usr/bin/env bash
# Verify that the resume_offset in disks.nix matches the actual swapfile.
#
# Run after: fresh install, swapfile recreate, BTRFS rebalance, kernel upgrades
# that change BTRFS layout, or any time hibernation breaks silently.
#
# Usage: ./scripts/verify-resume-offset.sh
#
# Exits 0 if the offset matches, 1 if it doesn't (with the value you should
# paste into modules/nixos/system/disks.nix).

set -euo pipefail

SWAPFILE="/swap/swapfile"
NIX_FILE="${BASH_SOURCE%/*}/../modules/nixos/system/disks.nix"

if [[ ! -f "$SWAPFILE" ]]; then
  echo "swapfile not found at $SWAPFILE" >&2
  exit 1
fi

actual=$(sudo btrfs inspect-internal map-swapfile -r "$SWAPFILE")
declared=$(grep -oP 'resume_offset=\K[0-9]+' "$NIX_FILE" || echo "")

echo "actual   physical start: $actual"
echo "declared resume_offset:  ${declared:-<unset>}"

if [[ "$actual" != "$declared" ]]; then
  echo
  echo "MISMATCH — hibernation will resume to wrong physical block."
  echo "Update disks.nix: resume_offset=$actual"
  exit 1
fi

echo "match — hibernation resume offset is correct"
