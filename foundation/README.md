# Docker Lab Foundation

Minimal standalone infrastructure layer for docker-lab-stack-test.

## Overview

This directory provides the foundation services that would normally come from the full `peer-mesh-docker-lab` repository. It enables **standalone mode** for testing and development without external dependencies.

## Services Provided

| Service | Image | Purpose | Profile |
|---------|-------|---------|---------|
| Traefik | traefik:v3.0 | Reverse proxy, TLS termination | traefik, minimal, full |
| PostgreSQL | pgvector/pgvector:pg16 | Relational database | postgresql, full |
| MySQL | mysql:8.0 | Relational database | mysql, full |
| MongoDB | mongo:6.0 | Document database | mongodb, full |
| Redis | redis:7-alpine | Cache & message queue | redis, full |
| MinIO | minio/minio:latest | S3-compatible storage | minio, full |

## Networks

| Network | Type | Purpose |
|---------|------|---------|
| pmdl_proxy-external | Bridge | Public-facing services (Traefik) |
| pmdl_db-internal | Bridge (internal) | Database access |
| pmdl_app-internal | Bridge (internal) | Inter-service communication |

## Usage

### Standalone Mode (Default)

The main docker-compose.yml includes this foundation by default:

```bash
# Generate secrets
./scripts/generate-secrets.sh

# Copy environment
cp .env.example .env

# Start foundation + application
docker compose --profile traefik --profile postgresql --profile gotosocial up -d
```

### With External Docker Lab

If you have the full `peer-mesh-docker-lab` repository:

```bash
# In .env, set:
DOCKER_LAB_PATH=../peer-mesh-docker-lab
```

## Database Initialization

Init scripts in `init-scripts/` are run on first container startup:

- `postgres/01-create-databases.sql` - Creates PostgreSQL databases and users
- `mysql/01-create-databases.sql` - Creates MySQL databases and users

**Important**: Default passwords in init scripts should be replaced via:
1. Docker secrets (preferred)
2. Environment variable substitution
3. Manual update after first run

## Resource Requirements

| Configuration | RAM Required |
|---------------|--------------|
| Traefik only | 128MB |
| Traefik + PostgreSQL | 1.5GB |
| Traefik + MySQL + PostgreSQL | 2.5GB |
| All services | 4GB |

## Files

```
foundation/
├── README.md                 # This file
├── docker-compose.yml        # Foundation services definition
└── init-scripts/
    ├── postgres/
    │   └── 01-create-databases.sql
    └── mysql/
        └── 01-create-databases.sql
```
