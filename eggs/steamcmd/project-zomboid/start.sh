#!/bin/bash

set -euo pipefail

cd /home/container

SERVER_NAME="${SERVER_NAME:-My Zomboid Server}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-}"
SERVER_PORT="${SERVER_PORT:-16261}"
MAX_PLAYERS="${MAX_PLAYERS:-16}"
PUBLIC_SERVER="${PUBLIC_SERVER:-false}"
PRESET_ADMIN_USERNAME="${PRESET_ADMIN_USERNAME:-admin}"
PAUSE_WHEN_EMPTY="${PAUSE_WHEN_EMPTY:-true}"
MOD_IDS="${MOD_IDS:-}"
WORKSHOP_IDS="${WORKSHOP_IDS:-}"
SERVER_PASSWORD="${SERVER_PASSWORD:-}"
JVM_OPTS="${JVM_OPTS:--Xmx8G -Xms4G}"
AUTO_UPDATE="${AUTO_UPDATE:-true}"

if [ "${AUTO_UPDATE}" = "true" ]; then
    echo "Running auto-update via SteamCMD..."
    steamcmd \
        +force_install_dir /home/container \
        +login anonymous \
        +app_update 380870 -beta "${STEAM_BRANCH}" validate \
        +quit
fi

mkdir -p /home/container/Zomboid/Server

INI_FILE="/home/container/Zomboid/Server/${SERVER_NAME}.ini"

if [ ! -f "${INI_FILE}" ]; then
    echo "Creating new server config: ${INI_FILE}"
    cat > "${INI_FILE}" << EOF
DefaultPort=${SERVER_PORT}
Password=${SERVER_PASSWORD}
Public=${PUBLIC_SERVER}
PublicDescription=
MaxPlayers=${MAX_PLAYERS}
ServerPlayerID=${PRESET_ADMIN_USERNAME}
PauseEmpty=${PAUSE_WHEN_EMPTY}
Mods=${MOD_IDS}
WorkshopItems=${WORKSHOP_IDS}
EOF
else
    update_ini() {
        local key="$1"
        local value="$2"
        local file="$3"
        if grep -q "^${key}=" "${file}" 2>/dev/null; then
            sed -i "s/^${key}=.*/${key}=${value}/" "${file}"
        else
            echo "${key}=${value}" >> "${file}"
        fi
    }

    update_ini "DefaultPort" "${SERVER_PORT}" "${INI_FILE}"
    update_ini "Password" "${SERVER_PASSWORD}" "${INI_FILE}"
    update_ini "Public" "${PUBLIC_SERVER}" "${INI_FILE}"
    update_ini "MaxPlayers" "${MAX_PLAYERS}" "${INI_FILE}"
    update_ini "ServerPlayerID" "${PRESET_ADMIN_USERNAME}" "${INI_FILE}"
    update_ini "PauseEmpty" "${PAUSE_WHEN_EMPTY}" "${INI_FILE}"
    update_ini "Mods" "${MOD_IDS}" "${INI_FILE}"
    update_ini "WorkshopItems" "${WORKSHOP_IDS}" "${INI_FILE}"
fi

export JVM_OPTS

ARGS=("-servername" "${SERVER_NAME}" "-cachedir=/home/container/Zomboid")

if [ -n "${ADMIN_PASSWORD}" ]; then
    ARGS+=("-adminpassword" "${ADMIN_PASSWORD}")
fi

echo "Starting Project Zomboid server: ${SERVER_NAME}"
echo "Port: ${SERVER_PORT} | Public: ${PUBLIC_SERVER} | Max Players: ${MAX_PLAYERS}"

exec ./start-server.sh "${ARGS[@]}"
