#!/bin/bash
set -euo pipefail

cd /mnt/server

## download and install steamcmd
STEAMCMD_URL="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
if [ ! -f "steamcmd/steamcmd.sh" ]; then
    echo "Installing SteamCMD..."
    mkdir -p steamcmd
    curl -sSL "${STEAMCMD_URL}" | tar -xvzf - -C steamcmd/
    chmod +x steamcmd/steamcmd.sh
else
    echo "SteamCMD already installed, skipping download."
fi

export STEAMCMD_DIR="./steamcmd"

## install game
echo "Installing Project Zomboid Dedicated Server..."
./steamcmd/steamcmd.sh \
    +force_install_dir /mnt/server \
    +login anonymous \
    +app_update 380870 -beta "${STEAM_BRANCH}" validate \
    +quit || echo "[WARN] SteamCMD install returned exit code $?"

echo "Game installed. Setting permissions..."
chmod -R o+w /mnt/server/steamapps/ || true

## download workshop mods
if [ -n "${WORKSHOP_IDS:-}" ]; then
    echo "Downloading workshop mods..."
    WS_ARGS=()
    OLD_IFS="${IFS}"
    IFS=";,"
    for wid in ${WORKSHOP_IDS}; do
        wid_trimmed="$(echo "${wid}" | xargs)"
        if [ -n "${wid_trimmed}" ]; then
            echo "  Queueing workshop item: ${wid_trimmed}"
            WS_ARGS+=(+workshop_download_item 108600 "${wid_trimmed}")
        fi
    done
    IFS="${OLD_IFS}"
    if [ ${#WS_ARGS[@]} -gt 0 ]; then
        ./steamcmd/steamcmd.sh \
            +login anonymous \
            "${WS_ARGS[@]}" \
            +quit || echo "  [WARN] SteamCMD workshop download returned exit code $?"
    fi
    echo "Workshop mod download complete."
    chmod -R o+w /mnt/server/steamapps/workshop/ || true
fi

## download workshop collection via Steam API
if [ -n "${COLLECTION_ID:-}" ]; then
    echo "Resolving workshop collection: ${COLLECTION_ID}..."
    COLLECTION_JSON="$(curl -s -X POST https://api.steampowered.com/ISteamRemoteStorage/GetCollectionDetails/v1/ \
        -d "collectioncount=1" \
        -d "publishedfileids[0]=${COLLECTION_ID}")"
    COLLECTION_ITEMS="$(echo "${COLLECTION_JSON}" | python3 -c "
import json,sys
data = json.load(sys.stdin)
items = []
for child in data['response']['collectiondetails'][0]['children']:
    items.append(str(child['publishedfileid']))
print(','.join(items))
" 2>/dev/null)"
    if [ -n "${COLLECTION_ITEMS}" ]; then
        echo "Collection contains items: ${COLLECTION_ITEMS}"
        OLD_IFS="${IFS}"
        IFS=","
        for ci in ${COLLECTION_ITEMS}; do
            echo "  Downloading workshop item: ${ci}"
            ./steamcmd/steamcmd.sh \
                +login anonymous \
                +workshop_download_item 108600 "${ci}" \
                +quit || echo "  [WARN] Failed to download collection item ${ci}"
        done
        IFS="${OLD_IFS}"
    else
        echo "  [WARN] Failed to resolve collection ${COLLECTION_ID} or collection is empty"
    fi
    echo "Collection download complete."
    chmod -R o+w /mnt/server/steamapps/workshop/ || true
fi

## create symlinks for workshop mods

echo "Creating symlinks for workshop mods..."
mkdir -p /mnt/server/Zomboid/Server /mnt/server/Zomboid/mods
for wid_dir in /mnt/server/steamapps/workshop/content/108600/*/; do
    if [ -d "${wid_dir}" ]; then
        for mod_dir in "${wid_dir}"mods/*/; do
            if [ -d "${mod_dir}" ]; then
                mod_info="${mod_dir}mod.info"
                if [ -f "${mod_info}" ]; then
                    mod_id="$(sed -n '/^[Ii][Dd]=/{s/^[Ii][Dd]=//;s/\r$//;p;q}' "${mod_info}")"
                    if [ -n "${mod_id}" ]; then
                        target="/mnt/server/Zomboid/mods/${mod_id}"
                        if [ ! -e "${target}" ]; then
                            ln -s "${mod_dir}" "${target}"
                            echo "  Linked ${mod_id}"
                        fi
                    fi
                fi
            fi
        done
    fi
done

## create start.sh
echo "Generating start.sh..."
cat > /mnt/server/start.sh << 'STARTSCRIPT'
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
COLLECTION_ID="${COLLECTION_ID:-}"
SERVER_PASSWORD="${SERVER_PASSWORD:-}"
JVM_OPTS="${JVM_OPTS:--Xmx8G -Xms4G}"
AUTO_UPDATE="${AUTO_UPDATE:-true}"

if [ "${AUTO_UPDATE}" = "true" ]; then
    echo "Running auto-update via SteamCMD..."
    steamcmd         +force_install_dir /home/container         +login anonymous         +app_update 380870 -beta "${STEAM_BRANCH}" validate         +quit || echo "[WARN] SteamCMD auto-update returned exit code $?, continuing..."
fi

if [ -n "${WORKSHOP_IDS:-}" ]; then
    echo "Downloading/updating workshop mods..."
    WS_ARGS=()
    OLD_IFS="${IFS}"
    IFS=";,"
    for wid in ${WORKSHOP_IDS}; do
        wid_trimmed="$(echo "${wid}" | xargs)"
        if [ -n "${wid_trimmed}" ]; then
            echo "  Workshop item: ${wid_trimmed}"
            WS_ARGS+=(+workshop_download_item 108600 "${wid_trimmed}")
        fi
    done
    IFS="${OLD_IFS}"
    if [ ${#WS_ARGS[@]} -gt 0 ]; then
        steamcmd             +force_install_dir /home/container             +login anonymous             "${WS_ARGS[@]}"             +quit || echo "  [WARN] SteamCMD workshop download returned exit code $?"
    fi
    echo "Workshop mod download complete."
fi

if [ -n "${COLLECTION_ID:-}" ]; then
    echo "Resolving workshop collection: ${COLLECTION_ID}..."
    COLLECTION_JSON="$(curl -s -X POST https://api.steampowered.com/ISteamRemoteStorage/GetCollectionDetails/v1/ \
        -d "collectioncount=1" \
        -d "publishedfileids[0]=${COLLECTION_ID}")"
    COLLECTION_ITEMS="$(echo "${COLLECTION_JSON}" | python3 -c "
import json,sys
data = json.load(sys.stdin)
items = []
for child in data['response']['collectiondetails'][0]['children']:
    items.append(str(child['publishedfileid']))
print(','.join(items))
" 2>/dev/null)"
    if [ -n "${COLLECTION_ITEMS}" ]; then
        echo "Collection contains items: ${COLLECTION_ITEMS}"
        OLD_IFS="${IFS}"
        IFS=","
        for ci in ${COLLECTION_ITEMS}; do
            echo "  Downloading workshop item: ${ci}"
            steamcmd \
                +force_install_dir /home/container \
                +login anonymous \
                +workshop_download_item 108600 "${ci}" \
                +quit || echo "  [WARN] Failed to download collection item ${ci}"
        done
        IFS="${OLD_IFS}"
    else
        echo "  [WARN] Failed to resolve collection ${COLLECTION_ID} or collection is empty"
    fi
    echo "Collection download complete."
fi

mkdir -p /home/container/Zomboid/{Server,mods}

echo "Creating/updating symlinks for workshop mods..."
for wid_dir in /home/container/steamapps/workshop/content/108600/*/; do
    if [ -d "${wid_dir}" ]; then
        for mod_dir in "${wid_dir}"mods/*/; do
            if [ -d "${mod_dir}" ]; then
                mod_info="${mod_dir}mod.info"
                if [ -f "${mod_info}" ]; then
                    mod_id="$(sed -n '/^[Ii][Dd]=/{s/^[Ii][Dd]=//;s/\r$//;p;q}' "${mod_info}")"
                    if [ -n "${mod_id}" ]; then
                        target="/home/container/Zomboid/mods/${mod_id}"
                        if [ ! -e "${target}" ]; then
                            ln -s "${mod_dir}" "${target}"
                            echo "  Linked ${mod_id}"
                        fi
                    fi
                fi
            fi
        done
    fi
done

INI_FILE="/home/container/Zomboid/Server/${SERVER_NAME}.ini"

if [ ! -f "${INI_FILE}" ]; then
    echo "Creating new server config: ${INI_FILE}"
    cat > "${INI_FILE}" << INIEOF
DefaultPort=${SERVER_PORT}
Password=${SERVER_PASSWORD}
Public=${PUBLIC_SERVER}
PublicDescription=
MaxPlayers=${MAX_PLAYERS}
ServerPlayerID=${PRESET_ADMIN_USERNAME}
PauseEmpty=${PAUSE_WHEN_EMPTY}
Mods=${MOD_IDS}
WorkshopItems=${WORKSHOP_IDS}
INIEOF
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
STARTSCRIPT

chmod +x /mnt/server/start.sh

echo "Installation complete."
