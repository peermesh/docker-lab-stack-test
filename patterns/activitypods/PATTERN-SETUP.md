# ActivityPods Pattern Setup Summary

## Pattern Overview

This pattern provides a Docker Compose configuration for deploying ActivityPods - a Solid + ActivityPub unified platform where WebID equals ActivityPub Actor.

## Files Included

| File | Description |
|------|-------------|
| `docker-compose.activitypods.yml` | Docker Compose fragment for ActivityPods stack |
| `README.md` | Pattern documentation and quick start guide |
| `PATTERN-SETUP.md` | This setup summary |

## Services Deployed

1. **Fuseki** - Apache Jena SPARQL triple store with WebACL support
2. **ActivityPods Backend** - Solid + ActivityPub unified API server
3. **ActivityPods Frontend** - User interface for pod management
4. **Arena** (optional) - Job queue monitor for background tasks

## Sanitization Applied

The following changes were made from the source files:

- Replaced project-specific prefixes (`pmdl_`) with generic `${COMPOSE_PROJECT_NAME:-lab}_`
- Changed default domain references to `example.com`
- Replaced branded instance names with generic defaults
- Removed internal file path references (`.dev/` paths)
- Updated compose file paths to use `patterns/` directory
- Removed references to internal research and proposal documents

## Prerequisites

1. Docker and Docker Compose installed
2. Traefik reverse proxy running (foundation stack)
3. Redis service available
4. Minimum 4GB RAM for Fuseki
5. Valid domain with DNS configured

## Required Secrets

Create these files before deployment:

```bash
mkdir -p secrets
openssl rand -hex 32 > secrets/fuseki_password
openssl rand -hex 64 > secrets/activitypods_cookie_secret
```

## Network Requirements

The pattern expects these external networks to exist:

- `${COMPOSE_PROJECT_NAME}_app-internal` - Internal service communication
- `${COMPOSE_PROJECT_NAME}_proxy-external` - Traefik proxy access

## Usage

```bash
# From the project root
docker compose -f docker-compose.yml \
               -f patterns/activitypods/docker-compose.activitypods.yml \
               --profile redis --profile activitypods up -d
```

## Customization

Set these environment variables in your `.env` file:

```env
DOMAIN=example.com
COMPOSE_PROJECT_NAME=myproject
ACTIVITYPODS_INSTANCE_NAME=My Pod Provider
ACTIVITYPODS_INSTANCE_DESCRIPTION=Self-hosted Solid+ActivityPub pods
```

## Created

- Date: 2026-01-02
- Source: Adapted from internal core patterns
