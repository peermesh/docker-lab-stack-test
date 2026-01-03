# GoToSocial Pattern

Ultra-lightweight ActivityPub microblogging platform. Alternative to Mastodon with 50-100MB RAM footprint.

## Why GoToSocial?

- **50-100MB RAM** vs 2-4GB for Mastodon
- Full ActivityPub compatibility
- Single Go binary
- SQLite default (simple backups)

## Quick Start

```bash
# Start GoToSocial
docker compose -f docker-compose.yml \
               -f patterns/gotosocial/docker-compose.gotosocial.yml \
               --profile gotosocial up -d

# Create first user
docker exec -it gotosocial /gotosocial/gotosocial admin account create \
    --username admin \
    --email admin@example.com \
    --password yourpassword
```

## Configuration

Set these environment variables in your `.env` file:

```bash
# Required
DOMAIN=example.com

# Optional
TZ=UTC
```

## Access

- **URL**: https://social.example.com (replace with your domain)
- **First setup**: Create admin via CLI (see above)

## Resource Requirements

| Resource | Allocation |
|----------|------------|
| RAM | 64-256MB |
| CPU | 0.25 cores |
| Disk | ~50MB + media |

## Features

- Full ActivityPub federation
- Mastodon API compatible clients
- Built-in media processing
- Allowlist/blocklist federation modes

## Integration

This pattern expects:
- Traefik reverse proxy on `proxy-external` network
- Let's Encrypt certificate resolver named `letsencrypt`

## Files

- `docker-compose.gotosocial.yml` - Docker Compose fragment for GoToSocial
- `README.md` - This documentation
- `PATTERN-SETUP.md` - Pattern adaptation notes
