# n8n Workflow Automation

Self-hosted workflow automation engine for POSSE syndication.

## Purpose

n8n serves as the central hub for syndicating content from the Fediverse to centralized platforms:

- **Bluesky** - AT Protocol, free API
- **Dev.to** - RSS import with canonical URL support
- **LinkedIn** - OAuth API (requires approval)
- **Buttondown** - Newsletter API ($9/mo)

## Quick Start

```bash
# 1. Generate secrets
mkdir -p secrets
echo "$(openssl rand -hex 32)" > secrets/n8n_encryption_key

# 2. Create n8n database
docker compose exec postgres psql -U postgres -c "CREATE DATABASE n8n;"
docker compose exec postgres psql -U postgres -c "CREATE USER n8n WITH PASSWORD 'your-password';"
docker compose exec postgres psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE n8n TO n8n;"

# 3. Start n8n
docker compose -f docker-compose.yml \
               -f patterns/n8n/docker-compose.n8n.yml \
               --profile postgresql --profile n8n up -d
```

## Access

- **URL**: https://n8n.example.com (replace with your domain)
- **First setup**: Create admin account on first visit

## POSSE Workflow Templates

Create a `workflows/` directory to store importable workflow templates:

- `bluesky-syndication.json` - Post to Bluesky from ActivityPub
- `devto-syndication.json` - Cross-post articles to Dev.to
- `newsletter-digest.json` - Weekly digest to Buttondown

## Resource Requirements

| Resource | Allocation |
|----------|------------|
| RAM | 256-512MB |
| CPU | 0.5 cores |
| Disk | ~100MB data |

## Integration Points

n8n receives webhooks from:

- ActivityPods (Solid+ActivityPub) create events
- WriteFreely new post events
- GoToSocial post events

And syndicates to:

- Bluesky (direct AT Protocol)
- Dev.to (REST API)
- LinkedIn (OAuth2)
- Buttondown (REST API)

## Environment Variables

Set these in your `.env` file:

```bash
DOMAIN=example.com
TZ=UTC
COMPOSE_PROJECT_NAME=stack
```
