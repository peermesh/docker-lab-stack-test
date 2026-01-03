# Pixelfed Pattern Setup Summary

## Pattern Overview

This pattern provides a Docker Compose configuration for Pixelfed, a federated image sharing platform (Instagram alternative) with full ActivityPub support.

## Files Created

| File | Purpose |
|------|---------|
| `docker-compose.pixelfed.yml` | Docker Compose fragment for Pixelfed services |
| `README.md` | User documentation and quick start guide |
| `PATTERN-SETUP.md` | This setup summary |

## Sanitization Applied

The following changes were made for public repository compliance:

1. **Container names**: Removed `pmdl_` prefix (e.g., `pmdl_pixelfed` -> `pixelfed`)
2. **Volume names**: Removed `pmdl_` prefix (e.g., `pmdl_pixelfed_storage` -> `pixelfed_storage`)
3. **Network names**: Removed specific project prefixes from external network declarations
4. **Domain defaults**: Changed to `example.com` with fallback defaults
5. **App name default**: Changed from project-specific to generic `My Photos`
6. **Admin email default**: Changed to `admin@example.com`
7. **Documentation paths**: Updated from `.dev/examples/` to `patterns/`
8. **No AGENTS.md or CLAUDE.md files**: Public repo compliance maintained

## Dependencies

This pattern requires:
- MySQL service (profile: `mysql`)
- Redis service (profile: `redis`)
- Traefik reverse proxy (foundation)
- External networks: `db-internal`, `app-internal`, `proxy-external`

## Usage

```bash
# Start with required profiles
docker compose -f docker-compose.yml \
               -f patterns/pixelfed/docker-compose.pixelfed.yml \
               --profile mysql --profile redis --profile pixelfed up -d
```

## Source

Adapted from: `peer-mesh-docker-lab/.dev/examples/pixelfed/`

## Date Created

2026-01-02
