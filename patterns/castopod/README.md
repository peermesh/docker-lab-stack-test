# Castopod - Federated Podcasting

Podcasting 2.0 platform with ActivityPub federation.

## Why Castopod?

- **Podcasting 2.0** features (chapters, transcripts, soundbites)
- **Value4Value** (Bitcoin/Lightning tips)
- **ActivityPub** federation (listeners can follow from Mastodon)
- Self-hosted podcast hosting

## Quick Start

```bash
# Requires MySQL + Redis
# 1. Create database
docker compose exec mysql mysql -u root -p -e "CREATE DATABASE castopod;"
docker compose exec mysql mysql -u root -p -e "CREATE USER 'castopod'@'%' IDENTIFIED BY 'password';"
docker compose exec mysql mysql -u root -p -e "GRANT ALL ON castopod.* TO 'castopod'@'%';"

# 2. Generate analytics salt
mkdir -p secrets
echo "$(openssl rand -hex 32)" > secrets/castopod_analytics_salt

# 3. Start Castopod
docker compose -f docker-compose.yml \
               -f patterns/castopod/docker-compose.castopod.yml \
               --profile mysql --profile redis --profile castopod up -d
```

## Configuration

Set the following in your `.env` file:

```bash
# Required
DOMAIN=example.com

# Optional (email)
SMTP_HOST=smtp.example.com
SMTP_USER=user@example.com
SMTP_PASS=your-password
SMTP_PORT=587
SMTP_CRYPTO=tls
CASTOPOD_FROM_EMAIL=podcast@example.com
```

## Access

- **URL**: https://podcast.example.com (replace with your domain)
- **Setup wizard**: First visit starts setup
- **ActivityPub**: Podcasts can be followed from any Fediverse app

## Resource Requirements

| Resource | Allocation |
|----------|------------|
| RAM | 256-512MB |
| CPU | 0.5 cores |
| Disk | ~50MB + episodes |

## Features

- Episode management with chapters
- Transcript support
- Soundbite clips
- Value4Value (Lightning payments)
- Advanced analytics
- Multiple podcast support
- ActivityPub federation

## Networks

This pattern expects the following external networks:

- `db-internal` - Database network
- `app-internal` - Application network
- `proxy-external` - Traefik proxy network

## Secrets

Create the following secret files before starting:

```bash
mkdir -p secrets
echo "$(openssl rand -hex 32)" > secrets/castopod_analytics_salt
echo "your-mysql-root-password" > secrets/mysql_root_password
```

## Dependencies

- MySQL (with `mysql` profile)
- Redis (with `redis` profile)
- Traefik (reverse proxy)
