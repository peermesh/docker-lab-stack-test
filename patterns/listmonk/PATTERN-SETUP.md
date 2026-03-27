# Listmonk Pattern Setup Summary

## Pattern Information

- **Name**: Listmonk Newsletter Manager
- **Version**: 1.0
- **Source**: Core Stack Examples
- **Created**: 2026-01-02

## Files Created

| File | Description |
|------|-------------|
| `docker-compose.listmonk.yml` | Docker Compose fragment for Listmonk service |
| `README.md` | Usage documentation and quick start guide |
| `PATTERN-SETUP.md` | This setup summary file |

## Changes from Source

The following sanitizations were applied for public repository compliance:

1. **Container naming**: Changed from hardcoded `pmdl_` prefix to dynamic `${COMPOSE_PROJECT_NAME:-stack}_` pattern
2. **Volume naming**: Updated to use `${COMPOSE_PROJECT_NAME:-stack}_` prefix for portability
3. **Network naming**: Updated external network references to use project name variable
4. **Domain defaults**: Changed to `example.com` placeholder
5. **Path references**: Updated from `.dev/examples/` to `patterns/` structure
6. **Documentation paths**: Updated to reflect new pattern location
7. **Removed**: All references to AGENTS.md, CLAUDE.md, and .dev/ internal structures

## Dependencies

- PostgreSQL (profile: postgresql)
- Traefik reverse proxy (foundation stack)
- Docker networks: db-internal, proxy-external

## Quick Verification

```bash
# Verify files exist
ls -la patterns/listmonk/

# Validate compose syntax
docker compose -f patterns/listmonk/docker-compose.listmonk.yml config
```

## Integration

To add this pattern to your stack:

1. Copy the `patterns/listmonk/` directory to your project
2. Add required environment variables to `.env`
3. Create the secrets file
4. Enable PostgreSQL profile
5. Run with the listmonk profile enabled
