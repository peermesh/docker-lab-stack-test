# Docker Lab Stack Test - Variations

This directory contains different deployment configurations for testing various scenarios.

## Available Variations

| Variation | Description | Use Case |
|-----------|-------------|----------|
| [minimal](./minimal/) | Traefik + GoToSocial + PostgreSQL | Core infrastructure testing |
| [full-stack](./full-stack/) | All services enabled | Comprehensive integration testing |

## Quick Reference

### Minimal

```bash
cd variations/minimal
cp .env.example .env
# Edit .env
docker compose -f ../../docker-compose.yml -f docker-compose.override.yml up -d
```

**Services**: Traefik, GoToSocial, PostgreSQL
**Memory**: ~512MB
**Best for**: Quick validation, CI/CD, resource-constrained environments

### Full Stack

```bash
cd variations/full-stack
cp .env.example .env
# Edit .env with all secrets
docker compose -f ../../docker-compose.yml -f docker-compose.override.yml up -d
```

**Services**: Traefik, PostgreSQL, Redis, Ghost, PeerTube, Matrix, Prometheus, Grafana
**Memory**: 4GB+
**Best for**: Production simulation, full integration testing

## How Variations Work

Each variation uses Docker Compose override files:

```
docker-lab-stack-test/
├── docker-compose.yml          # Base configuration (if any)
└── variations/
    ├── minimal/
    │   ├── docker-compose.override.yml  # Minimal services
    │   ├── .env.example                  # Minimal config
    │   └── README.md                     # Usage docs
    └── full-stack/
        ├── docker-compose.override.yml  # All services
        ├── .env.example                  # Full config
        └── README.md                     # Usage docs
```

## Usage Pattern

```bash
# Always specify both files
docker compose -f ../../docker-compose.yml -f docker-compose.override.yml [command]

# Common commands
docker compose ... up -d          # Start
docker compose ... down           # Stop
docker compose ... logs -f        # View logs
docker compose ... ps             # List containers
docker compose ... down -v        # Stop and remove volumes
```

## Creating New Variations

1. Create directory: `variations/your-variation/`
2. Add `docker-compose.override.yml` with your services
3. Add `.env.example` with required environment variables
4. Add `README.md` with usage instructions
5. Update this README and `docs/VARIATIONS.md`

### Template

```yaml
# docker-compose.override.yml
services:
  traefik:
    # Always include Traefik
    image: traefik:v3.0
    ...

  your-service:
    image: your/image:tag
    ...

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true

volumes:
  your_volume:
```

## Security Notes

All variations include:

- **Network isolation**: Backend network is internal-only
- **TLS by default**: Traefik handles Let's Encrypt
- **No exposed ports**: Only 80/443 via Traefik
- **Health checks**: All services include health verification

## Testing Variations

Run the test suite against any variation:

```bash
cd variations/minimal  # or full-stack
export VARIATION=minimal

# Run all tests
../../tests/security/run-all.sh
../../tests/integration/run-all.sh

# Run specific tests
../../tests/security/tls-check.sh
../../tests/integration/health-checks.sh
```

## Resource Comparison

| Variation | Memory | Disk | CPU | Startup Time |
|-----------|--------|------|-----|--------------|
| minimal | 512MB | 1GB | 1 core | ~30s |
| full-stack | 4GB+ | 10GB | 2+ cores | ~2min |

## Future Variations

Planned additions:

- `security-audit/` - Security-focused with minimal attack surface
- `media-heavy/` - PeerTube, Pixelfed, video transcoding
- `development/` - Hot reload, debug tools enabled
