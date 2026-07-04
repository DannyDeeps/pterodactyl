#!/bin/bash

set -euo pipefail

cd /mnt/server

SERVER_NAME="${SERVER_NAME:-My Zomboid Server}"
STEAM_USER="${STEAM_USER:-anonymous}"
STEAM_PASS="${STEAM_PASS:-}"
STEAM_BRANCH="${STEAM_BRANCH:-public}"
APP_ID=380870

export HOME=/mnt/server

if [ -n "${STEAM_PASS}" ]; then
    steamcmd \
        +force_install_dir /mnt/server \
        +login "${STEAM_USER}" "${STEAM_PASS}" \
        +app_update "${APP_ID}" -beta "${STEAM_BRANCH}" validate \
        +quit
else
    steamcmd \
        +force_install_dir /mnt/server \
        +login "${STEAM_USER}" \
        +app_update "${APP_ID}" -beta "${STEAM_BRANCH}" validate \
        +quit
fi

mkdir -p /mnt/server/Zomboid/Server

INI_FILE="/mnt/server/Zomboid/Server/${SERVER_NAME}.ini"
if [ ! -f "${INI_FILE}" ]; then
    cat > "${INI_FILE}" << EOF
DefaultPort=${SERVER_PORT:-16261}
Password=${SERVER_PASSWORD:-}
Public=${PUBLIC_SERVER:-false}
PublicDescription=
MaxPlayers=${MAX_PLAYERS:-16}
ServerPlayerID=${PRESET_ADMIN_USERNAME:-admin}
PauseEmpty=${PAUSE_WHEN_EMPTY:-true}
Mods=${MOD_IDS:-}
WorkshopItems=${WORKSHOP_IDS:-}
EOF
    echo "Created default server config: ${INI_FILE}"
fi

echo "Installation complete."
