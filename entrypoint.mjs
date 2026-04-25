import { execFileSync } from "node:child_process";
import { existsSync, readFileSync, writeFileSync, cpSync } from "node:fs";

const { STEAM_USERNAME = "", STEAM_PASSWORD = "" } = process.env;

// Validate Steam credentials
if (STEAM_USERNAME === "anonymous") {
  console.log("Using anonymous login. No password needed.");
} else if (!STEAM_USERNAME || !STEAM_PASSWORD) {
  console.error(
    "Please set STEAM_USERNAME and STEAM_PASSWORD environment variables.\n" +
      "If you want to use anonymous login, set STEAM_USERNAME to 'anonymous' and leave STEAM_PASSWORD empty.",
  );
  process.exit(1);
}

// Install game server via steamcmd
execFileSync(
  "steamcmd",
  [
    "+login",
    STEAM_USERNAME,
    STEAM_PASSWORD || "",
    "+force_install_dir",
    "/app",
    "+app_update",
    "3930080",
    "validate",
    "+quit",
  ],
  { stdio: "inherit" },
);

// Apply overlay if it exists
if (existsSync("/overlay")) {
  console.log("Applying overlay from /overlay to /app");
  cpSync("/overlay", "/app", { recursive: true });
}

// Handle configuration file changes via environment variables
const CONFIG_FIELDS = [
  { name: "MissionDirectory", type: "string" },
  { name: "ModdedServer", type: "boolean" },
  { name: "Hidden", type: "boolean" },
  { name: "ServerName", type: "string" },
  { name: "Password", type: "string" },
  { name: "MaxPlayers", type: "number" },
  { name: "DisableErrorKick", type: "boolean" },
  { name: "NoPlayerStopTime", type: "number" },
  { name: "PostMissionDelay", type: "number" },
  { name: "RotationType", type: "number" },
];

const CONFIG_PATH = "/app/DedicatedServerConfig.json";
const config = JSON.parse(readFileSync(CONFIG_PATH, "utf-8"));

for (const { name, type } of CONFIG_FIELDS) {
  const envVar = process.env[`CONFIG_${name.toUpperCase()}`];
  if (envVar == null || envVar === "") continue;

  console.log(`Setting ${name} to ${envVar} in ${CONFIG_PATH}`);

  if (!(name in config)) continue;

  switch (type) {
    case "boolean":
      config[name] = envVar === "true";
      break;
    case "number":
      config[name] = Number(envVar);
      break;
    default:
      config[name] = envVar;
      break;
  }
}

writeFileSync(CONFIG_PATH, JSON.stringify(config, null, 2) + "\n");

// Do we have any workshop items to download?
if (process.env.WORKSHOP_ITEMS) {
  const itemIds = process.env.WORKSHOP_ITEMS.split(",").map((id) => id.trim());
  console.log(`Downloading workshop items: ${itemIds.join(", ")}`);
  for (const itemId of itemIds) {
    execFileSync(
      "steamcmd",
      [
        "+login",
        STEAM_USERNAME,
        STEAM_PASSWORD || "",
        "+workshop_download_item",
        "3930080",
        itemId,
        "+quit",
      ],
      { stdio: "inherit" },
    );
  }

  // Move downloaded workshop items to the /app/Mods directory
  const steamWorkshopPath = `/home/steam/Steam/steamapps/workshop/content/3930080`;
  const modsPath = `/app/Mods`;

  for (const itemId of itemIds) {
    const sourcePath = `${steamWorkshopPath}/${itemId}`;
    if (existsSync(sourcePath)) {
      console.log(`Copying workshop item ${itemId} to ${modsPath}`);
      cpSync(sourcePath, `${modsPath}/${itemId}`, { recursive: true });
    } else {
      console.warn(`Workshop item ${itemId} not found at ${sourcePath}`);
    }
  }
}

// Run the server
execFileSync("sh", ["/app/RunServer.sh"], { stdio: "inherit" });
