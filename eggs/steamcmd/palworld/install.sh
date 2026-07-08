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

## set up 64 bit libraries
mkdir -p /mnt/server/.steam/sdk64
cp -v steamcmd/linux64/steamclient.so /mnt/server/.steam/sdk64/steamclient.so || true

## copy template config file
echo "Copying template config file..."
if [ -f "/mnt/server/DefaultPalWorldSettings.ini" ]; then
    mkdir -p "/mnt/server/Pal/Saved/Config/LinuxServer"
    cp "/mnt/server/DefaultPalWorldSettings.ini" "/mnt/server/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini"
    echo "Config file created from template."
else
    echo "No DefaultPalWorldSettings.ini found - server will create one on first start."
fi

echo "Installation complete."
