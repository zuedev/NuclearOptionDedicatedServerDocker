# Nuclear Option Dedicated Server Docker

A Docker setup for running a [Nuclear Option](https://store.steampowered.com/app/2376900/Nuclear_Option/) dedicated server.

## Prerequisites

- Docker and Docker Compose
- A Steam account that owns Nuclear Option (or use anonymous login if the app supports it)

## Quick Start

1. Clone this repository.

2. Create a `.env` file with your Steam credentials:

   ```env
   STEAM_USERNAME=your_username
   STEAM_PASSWORD=your_password
   ```

   Or use anonymous login:

   ```env
   STEAM_USERNAME=anonymous
   ```

3. Start the server:

   ```sh
   docker compose up -d
   ```

The entrypoint will download/update the server files via SteamCMD, apply any overlay files, and launch the server.

## Configuration

### Server Config via Environment Variables

You can override fields in `DedicatedServerConfig.json` by setting environment variables prefixed with `CONFIG_` in your `.env` file. The field name is uppercased.

| Environment Variable      | Type    | Description                                    |
| ------------------------- | ------- | ---------------------------------------------- |
| `CONFIG_MISSIONDIRECTORY` | string  | Path to the missions directory                 |
| `CONFIG_MODDEDSERVER`     | boolean | Whether the server is modded (`true`/`false`)  |
| `CONFIG_HIDDEN`           | boolean | Hide the server from the browser               |
| `CONFIG_SERVERNAME`       | string  | Server name shown in the server browser        |
| `CONFIG_PASSWORD`         | string  | Server password (empty for no password)        |
| `CONFIG_MAXPLAYERS`       | number  | Maximum number of players                      |
| `CONFIG_DISABLEERRORKICK` | boolean | Disable kicking players on error               |
| `CONFIG_NOPLAYERSTOPTIME` | number  | Seconds before stopping when no players are on |
| `CONFIG_POSTMISSIONDELAY` | number  | Delay in seconds after a mission ends          |
| `CONFIG_ROTATIONTYPE`     | number  | Mission rotation type                          |

### Direct Config Editing

You can also edit `nuclearoption/DedicatedServerConfig.json` directly. This file is mounted into the container at `/app`.

### Overlay

Any files placed in an `overlay/` directory will be copied over the server installation at `/app` on each startup. This is useful for adding custom missions, mods, or overriding specific files.

## Volumes

| Host Path         | Container Path | Purpose                       |
| ----------------- | -------------- | ----------------------------- |
| `./nuclearoption` | `/app`         | Server installation directory |
| `./overlay`       | `/overlay`     | Optional file overlay         |

## Networking

The container uses `network_mode: host`, so the server binds directly to the host's network interfaces. No port mapping is needed.

## Logs

Server logs are written to `nuclearoption/logs/`.
