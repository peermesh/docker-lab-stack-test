# Variations Documentation

Complete documentation for core-stack-test deployment variations.

## Summary

This repository provides multiple deployment configurations (variations) to test different aspects of the core infrastructure patterns.

---

## Variation Index

| Name | Path | Purpose |
|------|------|---------|
| Minimal | `variations/minimal/` | Core infrastructure testing |
| Full Stack | `variations/full-stack/` | Comprehensive integration testing |

---

## Minimal Variation

**Location**: `variations/minimal/`

### Overview

The smallest testable deployment for validating core patterns:
- Traefik reverse proxy with automatic TLS
- GoToSocial as a lightweight application
- PostgreSQL database

### Files

| File | Purpose |
|------|---------|
| `docker-compose.override.yml` | Service definitions |
| `.env.example` | Configuration template |
| `README.md` | Usage instructions |

### Services

```
┌─────────────┐
│   Traefik   │ :80, :443
└──────┬──────┘
       │
┌──────┴──────┐
│ GoToSocial  │ :8080 (internal)
└──────┬──────┘
       │
┌──────┴──────┐
│ PostgreSQL  │ :5432 (internal)
└─────────────┘
```

### Resources

- Memory: 512MB minimum
- Disk: 1GB
- CPU: 1 core

### Usage

```bash
cd variations/minimal
cp .env.example .env
# Configure .env
docker compose -f ../../docker-compose.yml -f docker-compose.override.yml up -d
```

---

## Full Stack Variation

**Location**: `variations/full-stack/`

### Overview

Complete deployment with all patterns for integration testing:
- Traefik reverse proxy
- PostgreSQL + Redis shared infrastructure
- Ghost CMS (with MySQL)
- PeerTube video platform
- Matrix/Synapse messaging
- Prometheus + Grafana monitoring

### Files

| File | Purpose |
|------|---------|
| `docker-compose.override.yml` | All service definitions |
| `.env.example` | Full configuration template |
| `README.md` | Detailed usage instructions |

### Services

```
                         ┌─────────────┐
                         │   Traefik   │ :80, :443
                         └──────┬──────┘
        ┌────────────┬─────────┼─────────┬────────────┐
        │            │         │         │            │
 ┌──────┴─────┐ ┌────┴────┐ ┌──┴──┐ ┌────┴────┐ ┌─────┴─────┐
 │   Ghost    │ │PeerTube │ │Matrix│ │Grafana │ │Prometheus │
 └──────┬─────┘ └────┬────┘ └──┬──┘ └─────────┘ └───────────┘
        │            │         │
 ┌──────┴─────┐      └────┬────┘
 │Ghost MySQL │           │
 └────────────┘    ┌──────┴──────┐
                   │ PostgreSQL  │
                   │    Redis    │
                   └─────────────┘
```

### Resources

- Memory: 4GB minimum (8GB recommended)
- Disk: 10GB
- CPU: 2+ cores

### Usage

```bash
cd variations/full-stack
cp .env.example .env
# Configure all secrets in .env
docker compose -f ../../docker-compose.yml -f docker-compose.override.yml up -d
```

---

## Configuration Patterns

### Environment Variables

All variations use the same patterns:

| Variable | Description | Example |
|----------|-------------|---------|
| `DOMAIN` | Base domain | `example.com` |
| `ACME_EMAIL` | Let's Encrypt email | `admin@example.com` |
| `TRAEFIK_DASHBOARD_AUTH` | Basic auth credentials | `admin:$apr1$...` |
| `*_PASSWORD` | Service passwords | Generated 32+ char strings |

### Network Isolation

```yaml
networks:
  frontend:     # Public-facing services
    driver: bridge
  backend:      # Database, cache, internal
    driver: bridge
    internal: true  # No external access
```

### Health Checks

All services include health verification:

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U postgres"]
  interval: 10s
  timeout: 5s
  retries: 5
```

---

## Testing by Variation

### Minimal Tests

```bash
# Quick health check
curl -I https://social.${DOMAIN}

# Database connectivity
docker exec postgresql pg_isready -U postgres

# TLS verification
openssl s_client -connect social.${DOMAIN}:443
```

### Full Stack Tests

```bash
# All services health
for svc in blog video matrix grafana; do
  curl -I https://${svc}.${DOMAIN}
done

# Database verification
docker exec postgresql psql -U postgres -c "\l"
docker exec redis redis-cli -a ${REDIS_PASSWORD} ping

# Monitoring stack
curl -s https://prometheus.${DOMAIN}/api/v1/targets | jq '.data.activeTargets | length'
```

---

## Security Considerations

### Secrets Generation

```bash
# Passwords (32+ characters)
openssl rand -base64 32

# Hex secrets (64 characters)
openssl rand -hex 32

# Traefik basic auth
htpasswd -nb admin $(openssl rand -base64 16)
```

### Checklist

- [ ] All `CHANGEME_*` values replaced
- [ ] No default passwords in production
- [ ] ACME_EMAIL is valid
- [ ] Internal networks properly isolated
- [ ] No unnecessary port exposures

---

## Comparison Matrix

| Feature | Minimal | Full Stack |
|---------|---------|------------|
| Traefik | Yes | Yes |
| PostgreSQL | Yes | Yes |
| Redis | No | Yes |
| Ghost CMS | No | Yes |
| PeerTube | No | Yes |
| Matrix | No | Yes |
| Monitoring | No | Yes |
| Memory | 512MB | 4GB+ |
| Startup | 30s | 2min |
| Best For | CI/CD, Quick Tests | Integration, Production Sim |

---

## Troubleshooting

### Container Issues

```bash
# View logs
docker compose ... logs -f <service>

# Restart specific service
docker compose ... restart <service>

# Check resource usage
docker stats
```

### Network Issues

```bash
# Verify networks
docker network ls | grep -E 'frontend|backend'

# Check connectivity
docker exec <container> ping <other_container>
```

### TLS Issues

```bash
# Check certificate
docker exec traefik cat /letsencrypt/acme.json | jq '.letsencrypt'

# Verify from outside
curl -vI https://your.domain 2>&1 | grep -A5 'Server certificate'
```

---

## Future Variations

### Planned

| Name | Focus |
|------|-------|
| `security-audit` | Minimal attack surface, security scanning |
| `media-heavy` | Video transcoding, large storage |
| `development` | Hot reload, debug logging |
| `high-availability` | Replicated services, load balancing |

---

*Documentation updated: 2026-01-03*
