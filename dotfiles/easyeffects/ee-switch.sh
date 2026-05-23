#!/usr/bin/env bash
# Switch EasyEffects profile by copying the matching rc files into db/
# Usage: ee-switch.sh <profile-name>
# Profiles: xps-internal | z407 | pixel-buds-pro

PROFILE="${1:-xps-internal}"
CONFIG_DIR="${HOME}/.config/easyeffects"
PROFILES_DIR="${CONFIG_DIR}/profiles"
DB_DIR="${CONFIG_DIR}/db"

if [[ ! -d "${PROFILES_DIR}/${PROFILE}" ]]; then
    echo "Unknown profile: ${PROFILE}" >&2
    exit 1
fi

cp "${PROFILES_DIR}/${PROFILE}"/*.rc "${DB_DIR}/" 2>/dev/null
# Copy files without the rc suffix mapping
for f in "${PROFILES_DIR}/${PROFILE}"/*rc; do
    cp "$f" "${DB_DIR}/$(basename "$f")"
done

# Restart EasyEffects service to pick up new config
systemctl --user restart easyeffects.service
