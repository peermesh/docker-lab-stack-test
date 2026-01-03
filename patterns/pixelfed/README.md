# Pixelfed - Federated Image Sharing

Instagram alternative with full ActivityPub federation.

## Why Pixelfed?

- ActivityPub-native photo sharing
- Full federation with Mastodon, PeerTube
- Albums, stories, discover features
- Self-hosted, privacy-respecting

## Quick Start

```bash
# Requires MySQL + Redis
# 1. Create database
docker compose exec mysql mysql -u root -p -e "CREATE DATABASE pixelfed;"
docker compose exec mysql mysql -u root -p -e "CREATE USER 'pixelfed'@'%' IDENTIFIED BY 'password';"
docker compose exec mysql mysql -u root -p -e "GRANT ALL ON pixelfed.* TO 'pixelfed'@'%';"

# 2. Generate app key
echo "base64:$(openssl rand -base64 32)" > secrets/pixelfed_app_key

# 3. Start Pixelfed
docker compose -f docker-compose.yml \
               -f patterns/pixelfed/docker-compose.pixelfed.yml \
               --profile mysql --profile redis --profile pixelfed up -d

# 4. Run migrations
docker exec pixelfed php artisan migrate --force

# 5. Generate instance actor (for ActivityPub)
docker exec pixelfed php artisan instance:actor

# 6. Create admin user
docker exec -it pixelfed php artisan user:create
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DOMAIN` | `example.com` | Your domain |
| `PIXELFED_APP_NAME` | `My Photos` | Instance name |
| `PIXELFED_DESCRIPTION` | `Federated photo sharing` | Instance description |
| `ADMIN_EMAIL` | `admin@example.com` | Admin contact email |

## Access

- **URL**: https://photos.{DOMAIN}
- **ActivityPub**: @username@photos.{DOMAIN}

## Resource Requirements

| Component | RAM |
|-----------|-----|
| Pixelfed app | 512MB-1GB |
| Pixelfed worker | 256-512MB |
| **Total** | 1-1.5GB |

## Features

- Photo albums and collections
- Stories (ephemeral content)
- Discover/explore feeds
- Direct messages
- Full ActivityPub federation

## Network Requirements

This pattern expects the following external networks:
- `db-internal` - Database connectivity
- `app-internal` - Application inter-service communication
- `proxy-external` - Traefik reverse proxy

## Secrets

Create these files before starting:
- `./secrets/pixelfed_app_key` - Laravel app key
- `./secrets/mysql_root_password` - MySQL password for pixelfed user
