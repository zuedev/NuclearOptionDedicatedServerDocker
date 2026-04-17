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

# apply overlay if it exists
if [ -d "/overlay" ]; then
    echo "Applying overlay from /overlay to /app"
    cp -r /overlay/* /app/
fi

# handle configuration file changes via environment variables
# pattern is: even index is the field name, odd index is the type (String, Boolean, Integer)
CONFIG_FIELDS=(
    "MissionDirectory"
    "String"
    "ModdedServer"
    "Boolean"
    "Hidden"
    "Boolean"
    "ServerName"
    "String"
    "Password"
    "String"
    "MaxPlayers"
    "Integer"
    "DisableErrorKick"
    "Boolean"
    "NoPlayerStopTime"
    "Integer"
    "PostMissionDelay"
    "Integer"
    "RotationType"
    "Integer"
)

CONFIG_PATH="/app/DedicatedServerConfig.json"

for FIELD in "${CONFIG_FIELDS[@]}"; do
    ENV_VAR_NAME="CONFIG_${FIELD^^}"
    if [ -n "${!ENV_VAR_NAME}" ]; then
        echo "Setting $FIELD to ${!ENV_VAR_NAME} in $CONFIG_PATH"
        jq --arg value "${!ENV_VAR_NAME}" --arg field "$FIELD" '(.[$field] // empty) |= ($value | if type == "boolean" then (if $value == "true" then true else false end) elif type == "number" then ($value | tonumber) else $value end)' "$CONFIG_PATH" > "$CONFIG_PATH.tmp" && mv "$CONFIG_PATH.tmp" "$CONFIG_PATH"
    fi
done

# run the server
sh /app/RunServer.sh