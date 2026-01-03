# Manyfold Pattern Setup Summary

## Pattern Overview

**Manyfold** is a self-hosted 3D model library with ActivityPub federation support. This pattern provides a Docker Compose fragment for deploying Manyfold with Traefik reverse proxy, PostgreSQL, and Redis.

## Files Created

| File | Description |
|------|-------------|
| `docker-compose.manyfold.yml` | Docker Compose fragment for Manyfold service |
| `README.md` | Usage documentation and quick start guide |
| `PATTERN-SETUP.md` | This setup summary |

## Changes from Source

The following sanitizations were applied for public repository compliance:

1. **Domain references**: Changed to use `${DOMAIN:-example.com}` with example.com default
2. **Container naming**: Removed project-specific prefixes (e.g., `pmdl_manyfold` -> `manyfold`)
3. **Volume naming**: Removed project-specific prefixes (e.g., `pmdl_manyfold_config` -> `manyfold_config`)
4. **Network references**: Removed project-specific network names, using generic external network references
5. **Documentation paths**: Updated from `.dev/examples/` to `patterns/` structure
6. **Password placeholders**: Updated to use generic placeholders (`your-password`)

## Dependencies

- **PostgreSQL**: Database backend (profile: `postgresql`)
- **Redis**: Cache and background jobs (profile: `redis`)
- **Traefik**: Reverse proxy for HTTPS termination

## Secrets Required

Create the following files in your `secrets/` directory:

```bash
mkdir -p secrets
docker run --rm lscr.io/linuxserver/manyfold:latest generate-secret > secrets/manyfold_secret_key
echo "your-postgres-password" > secrets/postgres_password
```

## Quick Deployment

```bash
# 1. Create required networks (if not exists)
docker network create db-internal
docker network create app-internal
docker network create proxy-external

# 2. Set up secrets
mkdir -p secrets
docker run --rm lscr.io/linuxserver/manyfold:latest generate-secret > secrets/manyfold_secret_key

# 3. Configure environment
export DOMAIN=example.com
export MANYFOLD_DB_PASSWORD=your-secure-password

# 4. Deploy
docker compose -f docker-compose.yml \
               -f patterns/manyfold/docker-compose.manyfold.yml \
               --profile postgresql --profile redis --profile manyfold up -d
```

## Public Repository Compliance

This pattern has been sanitized for public repositories:
- No AGENTS.md references
- No CLAUDE.md references
- No .dev/ directory references
- No client-specific configurations
- Uses example.com as default domain
