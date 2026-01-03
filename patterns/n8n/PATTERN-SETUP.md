# n8n Pattern Setup Summary

## Pattern Overview

This pattern provides a production-ready n8n workflow automation service configured for:

- POSSE (Publish on Own Site, Syndicate Elsewhere) syndication
- Integration with Traefik reverse proxy
- PostgreSQL database backend
- Docker secrets management

## Files Created

| File | Description |
|------|-------------|
| `docker-compose.n8n.yml` | Docker Compose fragment for n8n service |
| `README.md` | Usage documentation and quick start guide |
| `PATTERN-SETUP.md` | This setup summary |

## Key Features

- **Profile-based activation**: Only starts with `--profile n8n`
- **PostgreSQL backend**: Uses shared PostgreSQL instance
- **Traefik integration**: Auto-configured HTTPS via Let's Encrypt
- **Resource limits**: Memory capped at 512MB
- **Health checks**: Automatic container health monitoring
- **Secrets management**: Encryption key and database password via Docker secrets

## Prerequisites

1. Base stack with Traefik running
2. PostgreSQL service available
3. Networks created: `{project}_db-internal` and `{project}_proxy-external`
4. Secrets directory with required files

## Usage

```bash
# Start with PostgreSQL and n8n profiles
docker compose -f docker-compose.yml \
               -f patterns/n8n/docker-compose.n8n.yml \
               --profile postgresql --profile n8n up -d
```

## Customization Points

- `DOMAIN` - Set your domain in `.env`
- `COMPOSE_PROJECT_NAME` - Set project prefix for containers/networks
- `TZ` - Set timezone for scheduled workflows
- Volume mount for custom workflows directory

## Security Notes

- n8n encryption key protects stored credentials
- Runs behind Traefik with automatic TLS
- Telemetry disabled by default
- Secure cookies enabled

## Source

Adapted from peer-mesh-docker-lab n8n example pattern.
Sanitized for public repository use.
