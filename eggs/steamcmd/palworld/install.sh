#!/bin/bash
# steamcmd Base Installation Script
#
# Server Files: /mnt/server
# Image to install with is 'ghcr.io/ptero-eggs/installers:debian'


# Install packages. Default packages below are not required if using our existing install image thus speeding up the install process.
#apt -y update
#apt -y --no-install-recommends install curl lib32gcc-s1 ca-certificates

## just in case someone removed the defaults.
if [[ "${STEAM_USER}" == "" ]] || [[ "${STEAM_PASS}" == "" ]]; then
    echo -e "steam user is not set.\n"
    echo -e "Using anonymous user.\n"
    STEAM_USER=anonymous
    STEAM_PASS=""
    STEAM_AUTH=""
else
    echo -e "user set to ${STEAM_USER}"
fi

## download and install steamcmd
cd /tmp
mkdir -p /mnt/server/steamcmd
curl -sSL -o steamcmd.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xzvf steamcmd.tar.gz -C /mnt/server/steamcmd
cd /mnt/server/steamcmd
mkdir -p steamapps # SteamCMD needs steamapps in its working directory for app manifests

# SteamCMD fails otherwise for some reason, even running as root.
# This is changed at the end of the install process anyways.
chown -R root:root /mnt
export HOME=/mnt/server

## install game using steamcmd
./steamcmd.sh +force_install_dir /mnt/server +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} $( [[ "${WINDOWS_INSTALL}" == "1" ]] && printf %s '+@sSteamCmdForcePlatformType windows' ) +app_update ${SRCDS_APPID} $( [[ -z ${SRCDS_BETAID} ]] || printf %s "-beta ${SRCDS_BETAID}" ) $( [[ -z ${SRCDS_BETAPASS} ]] || printf %s "-betapassword ${SRCDS_BETAPASS}" ) ${INSTALL_FLAGS} validate +quit ## other flags may be needed depending on install. looking at you cs 1.6

## set up 32 bit libraries
mkdir -p /mnt/server/.steam/sdk32
cp -v linux32/steamclient.so ../.steam/sdk32/steamclient.so

## set up 64 bit libraries
mkdir -p /mnt/server/.steam/sdk64
cp -v linux64/steamclient.so ../.steam/sdk64/steamclient.so
## add below your custom commands if needed

## copy template config file
echo "Copy template config file into config folder!"
if [ -f "/mnt/server/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini" ]; then
    echo "Config file already exitis, backing up and overwriting with a new one"
    mv /mnt/server/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini /mnt/server/Pal/Saved/Config/LinuxServer/PalWorldSettings_$(date +"%Y%m%d%H%M%S").ini
    cp /mnt/server/DefaultPalWorldSettings.ini /mnt/server/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
else
    echo "Creating new config file"
    mkdir -p /mnt/server/Pal/Saved/Config/LinuxServer
    cp /mnt/server/DefaultPalWorldSettings.ini /mnt/server/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi

cd /mnt/server
# Download self made replace tool
echo "Downloading config parser application"
curl -sSL -o PalworldServerConfigParser https://github.com/pelican-eggs/Palworld-Config-Parser-Tool/releases/latest/download/PalworldServerConfigParser-linux-amd64
chmod +x PalworldServerConfigParser

## install end
echo "-----------------------------------------"
echo "Installation completed..."
echo "-----------------------------------------"
