#!/bin/bash

# do we have a username and password?
if [ "$STEAM_USERNAME" = "anonymous" ]; then
    echo "Using anonymous login. No password needed."
    STEAM_PASSWORD=""
elif [ -z "$STEAM_USERNAME" ] || [ -z "$STEAM_PASSWORD" ]; then
    echo "Please set STEAM_USERNAME and STEAM_PASSWORD environment variables."
    echo "If you want to use anonymous login, set STEAM_USERNAME to 'anonymous' and leave STEAM_PASSWORD empty."
    exit 1
fi

# install game server via steamcmd
steamcmd +login "$STEAM_USERNAME" "$STEAM_PASSWORD" +force_install_dir /app +app_update 3930080 validate +quit

# handle configuration file changes
CONFIG_FIELDS=(
    "ServerName"
    "MaxPlayers"
    "Password"
)

CONFIG_PATH="/app/DedicatedServerConfig.json"

for FIELD in "${CONFIG_FIELDS[@]}"; do
    ENV_VAR="CONFIG_${FIELD^^}"
    if [ -n "${!ENV_VAR}" ]; then
        echo "Setting $FIELD to ${!ENV_VAR} in config file."
        jq --arg value "${!ENV_VAR}" ".${FIELD} = \$value" "$CONFIG_PATH" > tmp.$$.json && mv tmp.$$.json "$CONFIG_PATH"
    fi
done

# run the server
sh /app/RunServer.sh