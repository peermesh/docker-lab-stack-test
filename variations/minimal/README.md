# Minimal Variation

The smallest testable deployment: Traefik + GoToSocial + PostgreSQL.

## Purpose

Test the core infrastructure patterns:
- Traefik reverse proxy with TLS
- Single application behind proxy
- PostgreSQL database connectivity
- Network isolation (frontend/backend)

## Services

| Service | Port | Description |
|---------|------|-------------|
| Traefik | 80, 443 | Reverse proxy with auto-TLS |
| GoToSocial | 8080 (internal) | ActivityPub server |
| PostgreSQL | 5432 (internal) | Database |

## Quick Start

```bash
# 1. Navigate to this directory
cd variations/minimal

# 2. Create environment file
cp .env.example .env

# 3. Edit .env with your settings
# - Set DOMAIN
# - Set ACME_EMAIL
# - Generate secure POSTGRES_PASSWORD
# - Generate TRAEFIK_DASHBOARD_AUTH

# 4. Start the stack
docker compose -f ../../docker-compose.yml -f docker-compose.override.yml up -d

# 5. Check status
docker compose -f ../../docker-compose.yml -f docker-compose.override.yml ps
```

## Endpoints

| URL | Service |
|-----|---------|
| `https://social.{DOMAIN}` | GoToSocial |
| `https://traefik.{DOMAIN}` | Traefik Dashboard (auth required) |

## Security Checklist

- [ ] POSTGRES_PASSWORD is randomly generated (32+ chars)
- [ ] TRAEFIK_DASHBOARD_AUTH uses strong password
- [ ] ACME_EMAIL is valid for certificate notifications
- [ ] PostgreSQL not exposed to public network

## Testing

```bash
# Health check
curl -I https://social.${DOMAIN}

# Database connectivity
docker exec postgresql pg_isready -U postgres

# TLS validation
openssl s_client -connect social.${DOMAIN}:443 -servername social.${DOMAIN}
```

## Cleanup

```bash
# Stop and remove containers
docker compose -f ../../docker-compose.yml -f docker-compose.override.yml down

# Remove volumes (WARNING: deletes data)
docker compose -f ../../docker-compose.yml -f docker-compose.override.yml down -v
```

## Resource Requirements

- Memory: ~512MB minimum
- Disk: ~1GB for images + data
- CPU: 1 core sufficient
