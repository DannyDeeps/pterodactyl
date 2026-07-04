# Pterodactyl

My personal collection of Pterodactyl Eggs & Yolks.

## Structure

```
yolks/                          # Docker images (runtime environments)
  project-zomboid/              # Debian + SteamCMD + Java 17 for PZ
  composer-php-app/             # Alpine + PHP 8 for composer apps

eggs/                           # Pterodactyl egg definitions
  steamcmd/
    project-zomboid/            # Project Zomboid server egg
      egg.json                  # Importable egg definition
      install.sh                # Install script (SteamCMD + config setup)
      start.sh                  # Startup script (config gen + server launch)
```

## Eggs

| Game              | Status         | Notes                              |
|-------------------|----------------|------------------------------------|
| Project Zomboid   | Active         | Custom yolk, auto-update, mods     |

## Usage

1. Build the yolk (Docker image) and push to a registry:
   ```bash
   docker build -t ghcr.io/dannydeeps/yolks:project-zomboid yolks/project-zomboid/
   docker push ghcr.io/dannydeeps/yolks:project-zomboid
   ```

2. Import the egg in Pterodactyl Admin Panel:
   - Admin → Nests → Import Egg
   - Select `eggs/steamcmd/project-zomboid/egg.json`
   - Update the Docker image URL to match your registry
