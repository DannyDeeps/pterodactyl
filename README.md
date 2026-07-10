# Pterodactyl

My personal collection of Pterodactyl Eggs & Yolks.

## Structure

```
yolks/                          # Docker images (runtime environments)
  steamcmd/                     # Debian + SteamCMD (base)
  steamcmd-java17/              # Extends steamcmd + Java 17 for PZ
  composer-php-app/             # Alpine + PHP 8 for composer apps

eggs/                           # Pterodactyl egg definitions
  steamcmd/
    palworld/                   # Palworld server egg
      egg.json                  # Importable egg definition
      install.sh                # Install script (SteamCMD + config setup)
      start.sh                  # Startup script (config gen + server launch)
    project-zomboid/            # Project Zomboid server egg
      egg.json                  # Importable egg definition
      install.sh                # Install script (SteamCMD + config setup)
      start.sh                  # Startup script (config gen + server launch)
    runescape-dragonwilds/      # RuneScape: Dragonwilds server egg
      egg.json                  # Importable egg definition
      install.sh                # Install script (SteamCMD + config setup)
      start.sh                  # Startup script (config gen + server launch)
```

## Eggs

| Game              | Status         | Notes                              |
|-------------------|----------------|------------------------------------|
| Palworld          | Active         | Custom yolk, auto-update, RCON, REST API |
| Project Zomboid   | Active         | Custom yolk, auto-update, mods     |
| RuneScape: Dragonwilds | Active     | SteamCMD, auto-update, config via env vars |

## Usage

1. Build the yolks (Docker images) and push to a registry:
   ```bash
   # Base SteamCMD image (build first)
   docker build -t ghcr.io/dannydeeps/yolks:steamcmd yolks/steamcmd/
   docker push ghcr.io/dannydeeps/yolks:steamcmd

   # Java 17 variant (extends base — must build after base)
   docker build -t ghcr.io/dannydeeps/yolks:steamcmd-java17 yolks/steamcmd-java17/
   docker push ghcr.io/dannydeeps/yolks:steamcmd-java17
   ```

2. Import the egg in Pterodactyl Admin Panel:
   - Admin → Nests → Import Egg
   - Select `eggs/steamcmd/palworld/egg.json`, `eggs/steamcmd/project-zomboid/egg.json`, or `eggs/steamcmd/runescape-dragonwilds/egg.json`
   - Update the Docker image URL to match your registry
