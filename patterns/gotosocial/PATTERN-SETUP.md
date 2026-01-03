# GoToSocial Pattern Setup

## Pattern Information

| Field | Value |
|-------|-------|
| Pattern Name | GoToSocial |
| Version | 1.0 |
| Source | Adapted from peer-mesh-docker-lab examples |
| Created | 2026-01-02 |

## What This Pattern Provides

A Docker Compose fragment for running GoToSocial, an ultra-lightweight ActivityPub microblogging server.

### Key Features

- **Minimal Resources**: 50-100MB RAM vs 2-4GB for Mastodon
- **Single Binary**: Simple Go application
- **SQLite Default**: Easy backups, no database server needed
- **Full Federation**: ActivityPub compatible with Mastodon ecosystem
- **Traefik Integration**: Automatic TLS via Let's Encrypt

## Files Included

```
patterns/gotosocial/
  README.md                      # User documentation
  docker-compose.gotosocial.yml  # Docker Compose fragment
  PATTERN-SETUP.md               # This file
```

## Adaptations Made

The following changes were made from the source pattern for public repository compliance:

1. **Container Naming**: Changed from `pmdl_gotosocial` to `gotosocial`
2. **Volume Naming**: Changed from `pmdl_gotosocial_data` to `gotosocial_data`
3. **Network Reference**: Simplified from `pmdl_proxy-external` to `proxy-external`
4. **Domain Default**: Added `${DOMAIN:-example.com}` fallback
5. **Path References**: Updated from `.dev/examples/` to `patterns/`
6. **Documentation Paths**: Updated to reflect new location

## Prerequisites

1. **Traefik Reverse Proxy**: Running and configured
2. **External Network**: `proxy-external` network created
3. **Environment Variables**: `DOMAIN` set in `.env`

## Quick Verification

```bash
# Verify files exist
ls -la patterns/gotosocial/

# Validate compose file syntax
docker compose -f docker-compose.yml \
               -f patterns/gotosocial/docker-compose.gotosocial.yml \
               config --quiet && echo "Valid"
```

## Usage

```bash
# Start the pattern
docker compose -f docker-compose.yml \
               -f patterns/gotosocial/docker-compose.gotosocial.yml \
               --profile gotosocial up -d

# Check status
docker compose ps

# View logs
docker logs -f gotosocial

# Create admin user
docker exec -it gotosocial /gotosocial/gotosocial admin account create \
    --username admin \
    --email admin@example.com \
    --password yourpassword
```

## Customization Points

| Setting | Environment Variable | Default |
|---------|---------------------|---------|
| Domain | `DOMAIN` | example.com |
| Timezone | `TZ` | UTC |
| Memory Limit | (in compose file) | 256M |
| Federation Mode | `GTS_INSTANCE_FEDERATION_MODE` | allowlist |

## Network Architecture

```
Internet
    |
    v
[Traefik] --> proxy-external network --> [GoToSocial:8080]
                                              |
                                              v
                                    [gotosocial_data volume]
```

## Public Repository Compliance

This pattern is prepared for public repositories:

- No private paths or references
- No internal project identifiers
- Uses example.com as default domain
- Self-contained documentation
- Standard naming conventions
