#!/bin/sh
cd /home/container

# Output Composer version
composer -V || { echo "[Composer] Error: Composer not detected."; exit 1; }

# Output PHP version
php -v || { echo "[PHP] Error: PHP not detected."; exit 1; }

# Make internal Docker IP address available to processes.
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Replace Startup Variables
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}