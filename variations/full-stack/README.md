# Full Stack Variation

Complete deployment with all patterns enabled for comprehensive testing.

## Purpose

Test the full infrastructure:
- Multiple applications behind Traefik
- PostgreSQL + Redis shared services
- Ghost CMS with MySQL
- PeerTube video platform
- Matrix/Synapse messaging
- Prometheus + Grafana monitoring

## Services

| Service | Port | Description |
|---------|------|-------------|
| Traefik | 80, 443 | Reverse proxy with auto-TLS |
| PostgreSQL | 5432 (internal) | Shared database |
| Redis | 6379 (internal) | Shared cache |
| Ghost | 2368 (internal) | Blog CMS |
| Ghost MySQL | 3306 (internal) | Ghost database |
| PeerTube | 9000 (internal) | Video platform |
| Synapse | 8008 (internal) | Matrix server |
| Prometheus | 9090 (internal) | Metrics |
| Grafana | 3000 (internal) | Dashboards |

## Quick Start

```bash
# 1. Navigate to this directory
cd variations/full-stack

# 2. Create environment file
cp .env.example .env

# 3. Generate all secrets
openssl rand -base64 32  # For each password
openssl rand -hex 32     # For PEERTUBE_SECRET
htpasswd -nb admin yourpassword  # For TRAEFIK_DASHBOARD_AUTH

# 4. Edit .env with your settings

# 5. Start the stack
docker compose -f ../../docker-compose.yml -f docker-compose.override.yml up -d

# 6. Check status
docker compose -f ../../docker-compose.yml -f docker-compose.override.yml ps
```

## Endpoints

| URL | Service |
|-----|---------|
| `https://traefik.{DOMAIN}` | Traefik Dashboard |
| `https://blog.{DOMAIN}` | Ghost CMS |
| `https://video.{DOMAIN}` | PeerTube |
| `https://matrix.{DOMAIN}` | Matrix/Synapse |
| `https://grafana.{DOMAIN}` | Grafana |
| `https://prometheus.{DOMAIN}` | Prometheus |

## Architecture

```
                    ┌─────────────┐
                    │   Traefik   │
                    │  (TLS/Proxy)│
                    └──────┬──────┘
           ┌───────────────┼───────────────┐
           │               │               │
    ┌──────┴──────┐ ┌──────┴──────┐ ┌──────┴──────┐
    │    Ghost    │ │  PeerTube   │ │   Synapse   │
    └──────┬──────┘ └──────┬──────┘ └──────┬──────┘
           │               │               │
    ┌──────┴──────┐        │               │
    │ Ghost MySQL │        └───────┬───────┘
    └─────────────┘                │
                            ┌──────┴──────┐
                            │ PostgreSQL  │
                            │    Redis    │
                            └─────────────┘
```

## Security Checklist

- [ ] All passwords randomly generated (32+ chars)
- [ ] TRAEFIK_DASHBOARD_AUTH uses strong password
- [ ] PEERTUBE_SECRET is 64-character hex
- [ ] ACME_EMAIL is valid
- [ ] PostgreSQL, Redis not exposed to public
- [ ] Ghost MySQL not exposed to public

## Testing

```bash
# Service health
./tests/integration/health-checks.sh

# TLS validation
./tests/security/tls-check.sh

# Database connectivity
docker exec postgresql pg_isready -U postgres
docker exec redis redis-cli -a ${REDIS_PASSWORD} ping

# Application checks
curl -I https://blog.${DOMAIN}
curl -I https://video.${DOMAIN}
curl -I https://matrix.${DOMAIN}/.well-known/matrix/server
```

## Resource Requirements

- Memory: 4GB minimum (8GB recommended)
- Disk: 10GB for images + data
- CPU: 2+ cores recommended

## First-Time Setup

### Ghost

1. Navigate to `https://blog.{DOMAIN}/ghost`
2. Complete the setup wizard
3. Create admin account

### PeerTube

1. Navigate to `https://video.{DOMAIN}`
2. Login with admin email from ACME_EMAIL
3. Check logs for initial password: `docker logs peertube`

### Matrix/Synapse

1. Generate config: `docker exec synapse generate`
2. Restart synapse after config changes
3. Create admin user via CLI

### Grafana

1. Navigate to `https://grafana.{DOMAIN}`
2. Login with GRAFANA_ADMIN_USER/PASSWORD
3. Add Prometheus data source: `http://prometheus:9090`

## Cleanup

```bash
# Stop containers
docker compose -f ../../docker-compose.yml -f docker-compose.override.yml down

# Remove volumes (WARNING: deletes all data)
docker compose -f ../../docker-compose.yml -f docker-compose.override.yml down -v
```

## Troubleshooting

### Container won't start
```bash
docker logs <container_name>
docker compose -f ../../docker-compose.yml -f docker-compose.override.yml logs -f
```

### Database connection issues
```bash
docker exec postgresql psql -U postgres -c "\l"
docker exec redis redis-cli -a ${REDIS_PASSWORD} info
```

### TLS certificate issues
```bash
docker exec traefik cat /letsencrypt/acme.json
# Check rate limits: https://letsencrypt.org/docs/rate-limits/
```
