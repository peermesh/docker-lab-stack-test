# Manyfold - 3D Model Library

Self-hosted 3D model manager with ActivityPub federation. **Fills the critical gap for 3D content in the Fediverse.**

## Why Manyfold?

- **Only** ActivityPub-enabled 3D model platform
- Supports STL, OBJ, 3MF, STEP, and more
- Built-in 3D preview
- Federation with f3di namespace

## Quick Start

```bash
# Requires PostgreSQL + Redis
# 1. Create database
docker compose exec postgres psql -U postgres -c "CREATE DATABASE manyfold;"
docker compose exec postgres psql -U postgres -c "CREATE USER manyfold WITH PASSWORD 'your-password';"
docker compose exec postgres psql -U postgres -c "GRANT ALL ON DATABASE manyfold TO manyfold;"

# 2. Generate secret key
docker run --rm lscr.io/linuxserver/manyfold:latest generate-secret > secrets/manyfold_secret_key

# 3. Start Manyfold
docker compose -f docker-compose.yml \
               -f patterns/manyfold/docker-compose.manyfold.yml \
               --profile postgresql --profile redis --profile manyfold up -d
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DOMAIN` | Your domain name | `example.com` |
| `TZ` | Timezone | `UTC` |
| `MANYFOLD_DB_PASSWORD` | Database password | `manyfold` |

## Access

- **URL**: `https://models.{DOMAIN}`
- **ActivityPub**: Collections can be followed from Mastodon

## Resource Requirements

| Resource | Allocation |
|----------|------------|
| RAM | 512MB-1GB |
| CPU | 0.5 cores |
| Disk | Depends on library size |

## Features

- 3D model preview in browser
- Tag and collection organization
- Automatic file analysis
- Print settings per model
- ActivityPub federation (f3di namespace)
- Remote following from Mastodon/etc.

## Mounting Libraries

Mount your existing 3D model directories:

```yaml
volumes:
  - /path/to/my/models:/libraries/my-collection
```

Manyfold will scan and index the models automatically.

## Network Requirements

This pattern requires the following external networks:
- `db-internal` - For database access
- `app-internal` - For inter-service communication
- `proxy-external` - For Traefik reverse proxy

## License

See [Manyfold GitHub](https://github.com/manyfold3d/manyfold) for license information.
