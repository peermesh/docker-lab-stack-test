# Core Stack Test - Compose Architecture

## Overview

This document describes the architecture of the Core Stack Test project, which imports the PeerMesh Core foundation and layers 10 Fediverse/POSSE applications on top.

## Architecture Diagram

```
+------------------------------------------------------------------+
|                    Core Stack Test                          |
+------------------------------------------------------------------+
|                                                                   |
|  +-------------------------------------------------------------+  |
|  |                    Application Layer                        |  |
|  |  (defined in this project's docker-compose.yml)            |  |
|  |                                                             |  |
|  |  +-------------+  +-------------+  +-------------+          |  |
|  |  | GoToSocial  |  | WriteFreely |  |  PeerTube   |          |  |
|  |  | (social)    |  | (blog)      |  | (peertube)  |          |  |
|  |  +-------------+  +-------------+  +-------------+          |  |
|  |                                                             |  |
|  |  +-------------+  +-------------+  +-------------+          |  |
|  |  |  Listmonk   |  |  rss2bsky   |  | ActivityPods|          |  |
|  |  | (newsletter)|  | (syndication)|  | (pods)      |          |  |
|  |  +-------------+  +-------------+  +-------------+          |  |
|  |                                                             |  |
|  |  +-------------+  +-------------+  +-------------+          |  |
|  |  |     n8n     |  |  Pixelfed   |  |  Castopod   |          |  |
|  |  | (automation)|  | (photos)    |  | (podcast)   |          |  |
|  |  +-------------+  +-------------+  +-------------+          |  |
|  |                                                             |  |
|  |  +-------------+                                            |  |
|  |  |  Manyfold   |                                            |  |
|  |  | (3d models) |                                            |  |
|  |  +-------------+                                            |  |
|  +-------------------------------------------------------------+  |
|                              |                                    |
|                              | include:                           |
|                              v                                    |
|  +-------------------------------------------------------------+  |
|  |               Foundation Layer (from core)            |  |
|  |                                                             |  |
|  |  +-------------------+  +-------------------------------+   |  |
|  |  |      Traefik      |  |    Database Profiles          |   |  |
|  |  | (reverse proxy)   |  | PostgreSQL | MySQL | MongoDB  |   |  |
|  |  | (TLS termination) |  | Redis      | MinIO            |   |  |
|  |  +-------------------+  +-------------------------------+   |  |
|  |                                                             |  |
|  |  +-------------------+  +-------------------------------+   |  |
|  |  |  Socket Proxy     |  |        Networks               |   |  |
|  |  | (Docker API)      |  | proxy-external | db-internal  |   |  |
|  |  +-------------------+  | app-internal   | socket-proxy |   |  |
|  |                         +-------------------------------+   |  |
|  +-------------------------------------------------------------+  |
|                                                                   |
+------------------------------------------------------------------+
```

## File Structure

```
core-stack-test/
├── docker-compose.yml          # Main orchestration file
├── .env.example                # Environment configuration template
├── .env                        # Local environment (gitignored)
├── secrets/                    # Generated secrets (gitignored)
│   ├── postgres_password
│   ├── mysql_root_password
│   ├── listmonk_db_password
│   ├── n8n_encryption_key
│   ├── fuseki_password
│   ├── activitypods_cookie_secret
│   ├── pixelfed_app_key
│   ├── castopod_analytics_salt
│   └── manyfold_secret_key
├── config/                     # Application configurations
│   └── writefreely/
│       └── config.ini
├── apps/                       # Application-specific files
│   ├── rss2bsky/
│   │   ├── Dockerfile
│   │   └── entrypoint.sh
│   └── n8n/
│       └── workflows/
├── docs/
│   └── COMPOSE-ARCHITECTURE.md
├── scripts/
│   └── generate-secrets.sh
└── tests/
```

## Applications Summary

| Application | Subdomain | Database | Profiles Required | RAM |
|-------------|-----------|----------|-------------------|-----|
| GoToSocial | social.${DOMAIN} | SQLite | gotosocial | 256MB |
| WriteFreely | blog.${DOMAIN} | MySQL | writefreely, mysql | 256MB |
| PeerTube | peertube.${DOMAIN} | PostgreSQL + Redis | peertube, postgresql | 2GB |
| Listmonk | newsletter.${DOMAIN} | PostgreSQL | listmonk, postgresql | 256MB |
| rss2bsky | (worker) | None | rss2bsky | 64MB |
| ActivityPods | pods.${DOMAIN} | Fuseki + Redis | activitypods, redis | 4GB+ |
| n8n | n8n.${DOMAIN} | PostgreSQL | n8n, postgresql | 512MB |
| Pixelfed | photos.${DOMAIN} | MySQL + Redis | pixelfed, mysql, redis | 1GB |
| Castopod | podcast.${DOMAIN} | MySQL + Redis | castopod, mysql, redis | 512MB |
| Manyfold | models.${DOMAIN} | PostgreSQL + Redis | manyfold, postgresql, redis | 1GB |

## Profile System

### Infrastructure Profiles (from foundation)

| Profile | Service | Purpose |
|---------|---------|---------|
| postgresql | PostgreSQL 16 + pgvector | Relational DB with vector support |
| mysql | MySQL 8.0 | Relational DB |
| mongodb | MongoDB 6.0 | Document DB |
| redis | Redis 7 | Cache/queue |
| minio | MinIO | S3-compatible storage |

### Application Profiles

| Profile | Applications | Description |
|---------|--------------|-------------|
| gotosocial | GoToSocial | Lightweight microblogging |
| writefreely | WriteFreely | Minimalist blogging |
| peertube | PeerTube, PeerTube-Redis | Video streaming |
| listmonk | Listmonk | Newsletter manager |
| rss2bsky | rss2bsky | Bluesky syndication |
| activitypods | Fuseki, ActivityPods Backend/Frontend | Solid+ActivityPub |
| n8n | n8n | Workflow automation |
| pixelfed | Pixelfed, Pixelfed-Worker | Image sharing |
| castopod | Castopod | Podcasting |
| manyfold | Manyfold | 3D model library |

### Meta Profiles

| Profile | Includes | Description |
|---------|----------|-------------|
| fediverse | gotosocial, writefreely, peertube, pixelfed, castopod, manyfold, activitypods | All ActivityPub apps |
| newsletter | listmonk | Email/newsletter apps |
| syndication | rss2bsky | Cross-posting apps |
| automation | n8n | Workflow apps |
| solid | activitypods | Solid protocol apps |
| full | All applications | Everything |

## Network Architecture

```
+------------------+     +------------------+     +------------------+
|  socket-proxy    |     |   proxy-external |     |   db-internal    |
|  (internal)      |     |   (external)     |     |   (internal)     |
+------------------+     +------------------+     +------------------+
        |                         |                       |
   Socket Proxy              Traefik <----+          PostgreSQL
        |                         |       |          MySQL
   Traefik                   GoToSocial   |          MongoDB
                             WriteFreely  |               |
                             PeerTube ----+---------+     |
                             Listmonk ----+---------+-----+
                             n8n ---------+---------+-----+
                             Pixelfed ----+---------+-----+
                             Castopod ----+---------+-----+
                             Manyfold ----+---------+-----+
                             ActivityPods-+---------+

+------------------+     +------------------+     +------------------+
|   app-internal   |     | peertube-internal|     | activitypods-int |
|   (internal)     |     |   (bridge)       |     |   (bridge)       |
+------------------+     +------------------+     +------------------+
        |                         |                       |
   Redis                  PeerTube                  Fuseki
   ActivityPods           PeerTube-Redis            ActivityPods-Backend
   Pixelfed-Worker
   Castopod
   Manyfold
```

## Secrets Management

All secrets are stored as files in the `secrets/` directory and mounted into containers. The pattern used is:

1. **File-based secrets**: Credentials read from `/run/secrets/<secret_name>`
2. **_FILE suffix**: Environment variables ending in `_FILE` point to secret files
3. **Never in environment**: Raw passwords are never stored in environment variables

### Secret Generation

```bash
# Generate all required secrets
./scripts/generate-secrets.sh

# Or manually:
openssl rand -hex 32 > secrets/postgres_password
openssl rand -hex 32 > secrets/mysql_root_password
openssl rand -hex 32 > secrets/listmonk_db_password
openssl rand -hex 32 > secrets/n8n_encryption_key
openssl rand -hex 32 > secrets/fuseki_password
openssl rand -hex 32 > secrets/activitypods_cookie_secret
php artisan key:generate --show > secrets/pixelfed_app_key  # or: base64:$(openssl rand -base64 32)
openssl rand -hex 32 > secrets/castopod_analytics_salt
docker run --rm lscr.io/linuxserver/manyfold:latest generate-secret > secrets/manyfold_secret_key
```

## Usage Examples

### Start Single Application

```bash
# GoToSocial only (uses embedded SQLite)
docker compose --profile gotosocial up -d

# WriteFreely (requires MySQL)
docker compose --profile writefreely --profile mysql up -d
```

### Start Multiple Applications

```bash
# Multiple Fediverse apps sharing databases
docker compose \
  --profile gotosocial \
  --profile writefreely \
  --profile listmonk \
  --profile postgresql \
  --profile mysql \
  up -d
```

### Start Everything

```bash
docker compose --profile full up -d
```

### Check Status

```bash
# Service status
docker compose ps

# View logs for specific service
docker compose logs -f gotosocial

# Resource usage
docker stats
```

## Database Initialization

Applications that require databases need their schemas initialized. This typically happens on first startup, but some applications need explicit initialization:

```bash
# Listmonk - install database schema
docker compose exec listmonk ./listmonk --install

# Pixelfed - run migrations
docker compose exec pixelfed php artisan migrate --force

# Castopod - install database schema
docker compose exec castopod php spark install:schema
```

## Resource Requirements

| Stack Configuration | RAM Required | Storage |
|---------------------|--------------|---------|
| GoToSocial only | 512MB | 1GB |
| Fediverse minimal (GtS + WriteFreely) | 2GB | 5GB |
| Full Fediverse stack | 8GB | 50GB |
| Full stack (all apps) | 12GB | 100GB |

## Integration with Foundation

The foundation is imported via Docker Compose's `include:` directive:

```yaml
include:
  - path: ${DOCKER_LAB_PATH:-../peermesh-core}/docker-compose.yml
```

**Standalone Mode (Default):** Uses the included `./foundation/` directory.
**External Mode:** Set `DOCKER_LAB_PATH=../peer-mesh-docker-lab` to use external docker-lab repo.

This provides:
- Traefik reverse proxy with automatic TLS
- Pre-configured networks (proxy-external, db-internal, app-internal)
- Database services (PostgreSQL, MySQL, MongoDB, Redis, MinIO)
- Resource limits and health checks
- Logging configuration

The networks are created by the foundation and automatically available to applications.

## Files Created

| File | Purpose |
|------|---------|
| `/Users/grig/work/peermesh/repo/core-stack-test/docker-compose.yml` | Main orchestration file with all 10 applications |
| `/Users/grig/work/peermesh/repo/core-stack-test/.env.example` | Environment configuration template with all variables |
| `/Users/grig/work/peermesh/repo/core-stack-test/docs/COMPOSE-ARCHITECTURE.md` | This architecture documentation |

## Next Steps

1. **Copy and configure environment**: `cp .env.example .env` and edit
2. **Generate secrets**: `./scripts/generate-secrets.sh`
3. **Create config directories**: Set up application-specific configs
4. **Start foundation first**: Ensure core foundation is running
5. **Start applications**: `docker compose --profile <profile> up -d`
6. **Initialize databases**: Run initialization commands for each app
7. **Configure DNS**: Point subdomains to your server
8. **Test federation**: Verify ActivityPub federation works

---

*Generated: 2026-01-02*
*Foundation: peermesh-core*
*Applications: 10 (GoToSocial, WriteFreely, PeerTube, Listmonk, rss2bsky, ActivityPods, n8n, Pixelfed, Castopod, Manyfold)*
