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
echo "Installing Palworld Dedicated Server..."
./steamcmd/steamcmd.sh \
    +@sSteamCmdForcePlatformType linux \
    +force_install_dir /mnt/server \
    +login anonymous \
    +app_update 2394010 validate \
    +quit || echo "[WARN] SteamCMD install returned exit code $?"

echo "Game installed. Setting permissions..."
chmod -R o+w /mnt/server/steamapps/ || true
chmod +x /mnt/server/PalServer.sh || true

## create start.sh
echo "Generating start.sh..."
cat > /mnt/server/start.sh << 'STARTSCRIPT'
#!/bin/bash
set -euo pipefail

cd /home/container

## read env vars with defaults
SERVER_NAME="${SERVER_NAME:-Palworld Server}"
SERVER_DESCRIPTION="${SERVER_DESCRIPTION:-}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-}"
SERVER_PASSWORD="${SERVER_PASSWORD:-}"
SERVER_PORT="${SERVER_PORT:-8211}"
MAX_PLAYERS="${MAX_PLAYERS:-32}"
PUBLIC_LOBBY="${PUBLIC_LOBBY:-false}"
PUBLIC_IP="${PUBLIC_IP:-}"
PUBLIC_PORT="${PUBLIC_PORT:-}"
RCON_ENABLED="${RCON_ENABLED:-false}"
RCON_PORT="${RCON_PORT:-25575}"
REST_API_ENABLED="${REST_API_ENABLED:-false}"
REST_API_PORT="${REST_API_PORT:-8212}"
AUTO_UPDATE="${AUTO_UPDATE:-true}"
USE_PERF_THREADS="${USE_PERF_THREADS:-true}"
WORKER_THREADS="${WORKER_THREADS:-}"

if [ "${AUTO_UPDATE}" = "true" ]; then
    echo "Running auto-update via SteamCMD..."
    steamcmd \
        +@sSteamCmdForcePlatformType linux \
        +force_install_dir /home/container \
        +login anonymous \
        +app_update 2394010 validate \
        +quit || echo "[WARN] SteamCMD auto-update returned exit code $?, continuing..."
fi

## ensure config directory exists
mkdir -p /home/container/Pal/Saved/Config/LinuxServer

CONFIG_FILE="/home/container/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini"

## build OptionSettings string
OPTIONS=""
append_val() {
    local key="$1"
    local value="$2"
    if [ -n "${OPTIONS}" ]; then
        OPTIONS="${OPTIONS},"
    fi
    OPTIONS="${OPTIONS}${key}=${value}"
}
append_str() {
    local key="$1"
    local value="$2"
    if [ -n "${OPTIONS}" ]; then
        OPTIONS="${OPTIONS},"
    fi
    OPTIONS="${OPTIONS}${key}=\"${value}\""
}

append_val "RCONEnabled" "${RCON_ENABLED}"
append_val "RCONPort" "${RCON_PORT}"
append_val "RESTAPIEnabled" "${REST_API_ENABLED}"
append_val "RESTAPIPort" "${REST_API_PORT}"

if [ -n "${SERVER_DESCRIPTION}" ]; then
    append_str "ServerDescription" "${SERVER_DESCRIPTION}"
fi

if [ -n "${ADMIN_PASSWORD}" ]; then
    append_str "AdminPassword" "${ADMIN_PASSWORD}"
fi

if [ -n "${SERVER_PASSWORD}" ]; then
    append_str "ServerPassword" "${SERVER_PASSWORD}"
fi

append_str "ServerName" "${SERVER_NAME}"
append_val "ServerPlayerMaxNum" "${MAX_PLAYERS}"

## write config file
{
    echo "[/Script/Pal.PalGameWorldSettings]"
    echo "OptionSettings=(${OPTIONS})"
} > "${CONFIG_FILE}"

echo "Configuration written to ${CONFIG_FILE}"

## build server arguments
ARGS=()
ARGS+=("-port=${SERVER_PORT}")
ARGS+=("-players=${MAX_PLAYERS}")
ARGS+=("-log")
ARGS+=("-logformat=text")

if [ "${PUBLIC_LOBBY}" = "true" ]; then
    ARGS+=("-publiclobby")
    if [ -n "${PUBLIC_IP}" ]; then
        ARGS+=("-publicip=${PUBLIC_IP}")
    fi
    if [ -n "${PUBLIC_PORT}" ]; then
        ARGS+=("-publicport=${PUBLIC_PORT}")
    fi
fi

if [ "${USE_PERF_THREADS}" = "true" ]; then
    ARGS+=("-useperfthreads" "-NoAsyncLoadingThread" "-UseMultithreadForDS")
    if [ -n "${WORKER_THREADS}" ]; then
        ARGS+=("-NumberOfWorkerThreadsServer=${WORKER_THREADS}")
    fi
fi

echo "Starting Palworld server: ${SERVER_NAME}"
echo "Port: ${SERVER_PORT} | Max Players: ${MAX_PLAYERS} | Public: ${PUBLIC_LOBBY}"

exec ./PalServer.sh "${ARGS[@]}"
STARTSCRIPT

chmod +x /mnt/server/start.sh

echo "Installation complete."
