# ActivityPods - Solid + ActivityPub Unified

SSI-first canonical data store with native ActivityPub federation.

## Why ActivityPods?

ActivityPods combines Solid (data sovereignty) with ActivityPub (federation) into a unified platform where **WebID = ActivityPub Actor**. This is the foundation for SSI-first content publishing.

## Features

- **Solid pods** for personal data storage
- **ActivityPub** native federation (works with Mastodon, PeerTube, etc.)
- **WebID authentication** for SSO
- **SPARQL** triple store (Fuseki) for semantic data

## Quick Start

```bash
# 1. Generate secrets
mkdir -p secrets
echo "$(openssl rand -hex 32)" > secrets/fuseki_password
echo "$(openssl rand -hex 64)" > secrets/activitypods_cookie_secret

# 2. Start foundation + redis
docker compose --profile redis up -d

# 3. Start ActivityPods
docker compose -f docker-compose.yml \
               -f patterns/activitypods/docker-compose.activitypods.yml \
               --profile redis --profile activitypods up -d
```

## Access

- **Pods**: https://pods.{DOMAIN}
- **Fuseki Admin**: Internal only (port 3030)
- **Arena (job monitor)**: https://arena.{DOMAIN} (with monitoring profile)

## Resource Requirements

| Component | RAM |
|-----------|-----|
| Fuseki (SPARQL) | 3-4GB |
| Backend | 512MB-1GB |
| Frontend | 128-256MB |
| **Total** | **4-5GB** |

**Warning**: 4GB RAM minimum. Fuseki will fail with less.

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| DOMAIN | Your domain (e.g., example.com) | Yes |
| ACTIVITYPODS_INSTANCE_NAME | Display name | No |
| ACTIVITYPODS_MAPBOX_TOKEN | Location autocomplete | No |
| SMTP_HOST, SMTP_USER, etc. | Email notifications | No |

## Federation

Once running, users can:
- Follow/be followed from Mastodon instances
- Publish content that federates across the Fediverse
- Maintain data sovereignty in their Solid pod

## References

- [ActivityPods Project](https://activitypods.org/)
- [Solid Project](https://solidproject.org/)
- [ActivityPub Spec](https://www.w3.org/TR/activitypub/)
