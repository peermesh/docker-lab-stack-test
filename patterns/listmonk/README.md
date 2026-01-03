# Listmonk - Newsletter Manager

Self-hosted newsletter and mailing list manager with a modern web UI.

## Why Listmonk?

- **50-100MB RAM** - lightweight Go binary
- Modern, responsive admin interface
- Subscriber segmentation and lists
- Campaign scheduling and analytics
- REST API for integrations
- Template editor with preview

## Quick Start

```bash
# 1. Generate secrets
mkdir -p secrets
openssl rand -base64 32 | tr -d '\n' > secrets/listmonk_db_password

# 2. Create database and user
docker compose exec postgres psql -U postgres -c "CREATE DATABASE listmonk;"
docker compose exec postgres psql -U postgres -c "CREATE USER listmonk WITH PASSWORD '$(cat secrets/listmonk_db_password)';"
docker compose exec postgres psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE listmonk TO listmonk;"

# 3. Start Listmonk
docker compose -f docker-compose.yml \
               -f patterns/listmonk/docker-compose.listmonk.yml \
               --profile postgresql --profile listmonk up -d

# 4. Run initial setup (first time only)
docker exec -it ${COMPOSE_PROJECT_NAME:-stack}_listmonk ./listmonk --install
```

## Access

- **URL**: https://newsletter.example.com (replace with your domain)
- **Admin**: Configure via LISTMONK_ADMIN_USER and LISTMONK_ADMIN_PASSWORD in .env

## Environment Variables

Add to your `.env`:

```bash
# Domain configuration
DOMAIN=example.com

# Listmonk Configuration
LISTMONK_ADMIN_USER=admin
LISTMONK_ADMIN_PASSWORD=your-secure-password
```

## Secrets Required

- `listmonk_db_password` - PostgreSQL database password

Generate the secret:

```bash
mkdir -p secrets
openssl rand -base64 32 | tr -d '\n' > secrets/listmonk_db_password
```

## Resource Requirements

| Resource | Allocation |
|----------|------------|
| RAM | 64-256MB |
| CPU | 0.1 cores |
| Disk | ~50MB + uploads |

## Features

- Subscriber management with custom attributes
- Multiple mailing lists
- Campaign templates (HTML/plaintext)
- Bounce and complaint handling
- Analytics and click tracking
- Import/export subscribers
- REST API

## SMTP Configuration

Configure SMTP in the Listmonk admin UI after first login:

1. Navigate to Settings > SMTP
2. Add your SMTP server details
3. Test the connection

## PostgreSQL Init Script (Optional)

If you want automatic database creation, add to your PostgreSQL init scripts:

```bash
#!/bin/bash
# 05-listmonk.sh
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE USER listmonk WITH PASSWORD '$(cat /run/secrets/listmonk_db_password)';
    CREATE DATABASE listmonk OWNER listmonk;
    GRANT ALL PRIVILEGES ON DATABASE listmonk TO listmonk;
EOSQL
```

## Network Requirements

This pattern expects the following networks to exist:
- `${COMPOSE_PROJECT_NAME}_db-internal` - Internal database network
- `${COMPOSE_PROJECT_NAME}_proxy-external` - External proxy network (Traefik)
