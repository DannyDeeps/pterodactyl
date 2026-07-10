#!/bin/bash

set -euo pipefail

cd /home/container

SERVER_PORT="${SERVER_PORT:-7777}"
OWNER_ID="${OWNER_ID:-}"
SERVER_NAME="${SERVER_NAME:-A Pterodactyl hosted Dragonwilds Server}"
DEFAULT_WORLD_NAME="${DEFAULT_WORLD_NAME:-Dragonwilds_World1}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-}"
WORLD_PASSWORD="${WORLD_PASSWORD:-}"
AUTO_UPDATE="${AUTO_UPDATE:-1}"

## auto-update via SteamCMD
if [ "${AUTO_UPDATE}" == "1" ]; then
    echo "Running auto-update via SteamCMD..."
    ./steamcmd/steamcmd.sh \
        +force_install_dir /home/container \
        +login anonymous \
        +app_update 4019830 \
        $( [[ -z ${SRCDS_BETAID:-} ]] || printf %s "-beta ${SRCDS_BETAID}" ) \
        $( [[ -z ${SRCDS_BETAPASS:-} ]] || printf %s "-betapassword ${SRCDS_BETAPASS}" ) \
        validate +quit
fi

## ensure config directory exists
CONFIG_DIR="/home/container/RSDragonwilds/Saved/Config/LinuxServer"
mkdir -p "${CONFIG_DIR}"

## generate DedicatedServer.ini
CONFIG_FILE="${CONFIG_DIR}/DedicatedServer.ini"

if [ ! -f "${CONFIG_FILE}" ]; then
    echo "Creating new server config: ${CONFIG_FILE}"
    cat > "${CONFIG_FILE}" << EOF
[/Script/RSDragonwilds.DedicatedServerSettings]
OwnerId=${OWNER_ID}
ServerName=${SERVER_NAME}
DefaultWorldName=${DEFAULT_WORLD_NAME}
AdminPassword=${ADMIN_PASSWORD}
WorldPassword=${WORLD_PASSWORD}
EOF
else
    echo "Updating existing server config: ${CONFIG_FILE}"

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

    update_ini "OwnerId" "${OWNER_ID}" "${CONFIG_FILE}"
    update_ini "ServerName" "${SERVER_NAME}" "${CONFIG_FILE}"
    update_ini "DefaultWorldName" "${DEFAULT_WORLD_NAME}" "${CONFIG_FILE}"
    update_ini "AdminPassword" "${ADMIN_PASSWORD}" "${CONFIG_FILE}"
    update_ini "WorldPassword" "${WORLD_PASSWORD}" "${CONFIG_FILE}"
fi

echo "Starting RuneScape: Dragonwilds server..."
echo "Port: ${SERVER_PORT} | Name: ${SERVER_NAME} | World: ${DEFAULT_WORLD_NAME}"

export HOME=/home/container

exec ./RSDragonwildsServer.sh -log -NewConsole -Port="${SERVER_PORT}"
