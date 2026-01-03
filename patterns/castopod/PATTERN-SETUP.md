# Castopod Pattern Setup Summary

## Pattern Overview

This pattern provides a Docker Compose fragment for deploying Castopod, a Podcasting 2.0 platform with ActivityPub federation.

## Files Created

| File | Description |
|------|-------------|
| `docker-compose.castopod.yml` | Docker Compose fragment for Castopod service |
| `README.md` | Pattern documentation and usage guide |
| `PATTERN-SETUP.md` | This setup summary |

## Changes from Source

The following sanitizations were applied for public repository compliance:

1. **Container naming**: Changed `pmdl_castopod` to `castopod` (removed prefix)
2. **Volume naming**: Changed `pmdl_castopod_media` to `castopod_media` (removed prefix)
3. **Network naming**: Removed `pmdl_` prefix from network names (now just `db-internal`, `app-internal`, `proxy-external`)
4. **Domain defaults**: Added `example.com` as default domain fallback
5. **Documentation paths**: Updated from `.dev/examples/` to `patterns/`
6. **Secrets directory**: Added explicit `mkdir -p secrets` in setup instructions

## Usage

```bash
# 1. Set up secrets
mkdir -p secrets
echo "$(openssl rand -hex 32)" > secrets/castopod_analytics_salt
echo "your-mysql-root-password" > secrets/mysql_root_password

# 2. Configure .env
echo "DOMAIN=your-domain.com" >> .env

# 3. Create database (if MySQL running)
docker compose exec mysql mysql -u root -p -e "CREATE DATABASE castopod;"
docker compose exec mysql mysql -u root -p -e "CREATE USER 'castopod'@'%' IDENTIFIED BY 'password';"
docker compose exec mysql mysql -u root -p -e "GRANT ALL ON castopod.* TO 'castopod'@'%';"

# 4. Start services
docker compose -f docker-compose.yml \
               -f patterns/castopod/docker-compose.castopod.yml \
               --profile mysql --profile redis --profile castopod up -d
```

## Prerequisites

- Docker and Docker Compose
- Traefik reverse proxy (foundation stack)
- MySQL service (with `mysql` profile)
- Redis service (with `redis` profile)
- Valid domain with DNS configured

## Integration Points

- **Traefik**: Exposes `podcast.${DOMAIN}` via HTTPS
- **MySQL**: Database backend for podcast data
- **Redis**: Caching layer for performance
- **Let's Encrypt**: Automatic TLS certificates

## Compliance Notes

- No AGENTS.md references
- No CLAUDE.md references
- No .dev/ directory references
- No client-specific naming conventions
- Uses example.com for all domain examples
