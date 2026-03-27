# rss2bsky Pattern Setup Summary

## Pattern Overview

**Name**: rss2bsky - RSS to Bluesky Syndication
**Purpose**: Lightweight cron-based RSS to Bluesky cross-posting
**Source**: Adapted from peermesh-core examples

## Files Created

| File | Description |
|------|-------------|
| `docker-compose.yml` | Main compose file with service definition |
| `Dockerfile` | Alpine-based Python container with cron |
| `entrypoint.sh` | Container startup script with cron setup |
| `sync.sh` | RSS sync script called by cron |
| `.env.example` | Template for environment configuration |
| `README.md` | Full documentation for the pattern |

## Sanitization Applied

- Removed all `pmdl_` prefixes from container and volume names
- Removed network references (proxy-external, pmdl_proxy-external)
- Removed profile configurations (rss2bsky, full)
- Removed Traefik and Watchtower labels
- Changed build context from `.dev/examples/rss2bsky` to `.`
- Replaced domain-specific URLs with `example.com` placeholders
- Removed GoToSocial-specific references (made generic RSS)
- Removed references to related examples (../gotosocial/, ../writefreely/)

## Quick Start

```bash
cd patterns/rss2bsky
cp .env.example .env
# Edit .env with your Bluesky credentials and RSS feed URL
docker compose up -d
```

## Resource Requirements

- Idle: 2-5MB RAM
- Active: ~20MB RAM
- Peak: ~30MB RAM
- Memory limit: 64MB

## Dependencies

- Python 3.12 (Alpine)
- dcron (Alpine cron daemon)
- rss2bsky Python package (installed via pip)

## Public Repo Compliance

- No AGENTS.md files
- No CLAUDE.md files
- No .dev/ directory references
- No client-specific domains or identifiers
- Generic example.com domains used
- MIT license reference in README
