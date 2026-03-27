# WriteFreely Pattern Setup Summary

## Pattern Overview

**WriteFreely** is a lightweight, minimalist blogging platform with native ActivityPub federation support. This pattern provides a Docker Compose fragment for deploying WriteFreely as part of a larger stack.

## Files Created

| File | Purpose |
|------|---------|
| `README.md` | Pattern documentation and quick start guide |
| `docker-compose.writefreely.yml` | Docker Compose fragment for WriteFreely service |
| `config/config.ini.template` | WriteFreely configuration template |
| `PATTERN-SETUP.md` | This setup summary |

## Sanitization Applied

The following changes were made to ensure public repository compliance:

1. **Domain references**: Changed from client-specific domains to `example.com` defaults
2. **Container naming**: Changed from `pmdl_writefreely` to generic `writefreely`
3. **Volume naming**: Changed from `pmdl_writefreely_data` to `writefreely_data`
4. **Network naming**: Changed from `pmdl_db-internal` and `pmdl_proxy-external` to generic `db-internal` and `proxy-external`
5. **Site name defaults**: Changed from client-specific to generic `My Blog`
6. **Documentation paths**: Updated to use `patterns/writefreely/` instead of `.dev/examples/writefreely/`
7. **Removed**: All references to AGENTS.md, CLAUDE.md, and .dev/ directories

## Key Features

- **Resource Efficient**: 64-256MB RAM, 0.1 CPU cores
- **ActivityPub Federation**: Native support for Mastodon/Fediverse integration
- **MySQL Backend**: Requires MySQL database
- **Traefik Integration**: Pre-configured for Traefik reverse proxy with Let's Encrypt
- **Docker Secrets**: Uses secrets for password management

## Usage

```bash
# Deploy with MySQL and WriteFreely profiles
docker compose -f docker-compose.yml \
               -f patterns/writefreely/docker-compose.writefreely.yml \
               --profile mysql --profile writefreely up -d
```

## Required Environment Variables

```bash
DOMAIN=example.com
WRITEFREELY_SITE_NAME=My Blog
WRITEFREELY_SINGLE_USER=false
```

## Prerequisites

1. Traefik reverse proxy running
2. MySQL service available (via `--profile mysql`)
3. Docker secrets configured at `./secrets/mysql_root_password`
4. Networks `db-internal` and `proxy-external` created

## Source

Adapted from internal Core patterns for public distribution.

---

*Generated: 2026-01-02*
