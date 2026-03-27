# README.md Update Summary

**Updated**: 2026-01-02

## Changes Made

### 1. Added Pattern Overview Table

Complete list of all 10 patterns with:
- Pattern name (linked to detail section)
- Service URL (*.dockerlab.peermesh.org)
- Status badge (ready/in-progress)
- Brief description

### 2. Added Quick Start Variations

Three deployment options documented:
- **Minimal Stack**: Core infrastructure only (Traefik, PostgreSQL, Redis)
- **Full Stack**: All patterns with monitoring (8GB+ RAM)
- **Single Pattern**: Deploy individual patterns via profiles

### 3. Pattern Details Section

Each pattern now includes:
- Description
- Service URL
- Technology stack
- Minimum RAM requirements
- Link to pattern-specific README
- Deployment command

### 4. VPS Deployment Instructions

New section covering:
- System requirements
- DNS configuration (all 9 subdomain mappings)
- Step-by-step deployment commands
- TLS/Let's Encrypt configuration

### 5. Status Badges

Added shields.io badges for:
- License (MIT)
- Docker version (24+)
- Compose version (v2)
- Individual pattern status

### 6. Updated Structure

Expanded directory tree to show:
- `patterns/` directory with all 10 pattern subdirectories
- Existing `variations/`, `tests/`, and `docs/` directories

---

## Patterns Documented

| # | Pattern | Subdomain | Category |
|---|---------|-----------|----------|
| 1 | GoToSocial | social.* | Social Network |
| 2 | WriteFreely | blog.* | Blogging |
| 3 | PeerTube | video.* | Video Hosting |
| 4 | Listmonk | newsletter.* | Email Marketing |
| 5 | rss2bsky | N/A (daemon) | Syndication |
| 6 | ActivityPods | pods.* | Data Storage |
| 7 | n8n | automation.* | Workflow |
| 8 | Pixelfed | photos.* | Image Sharing |
| 9 | Castopod | podcast.* | Podcast Hosting |
| 10 | Manyfold | models.* | 3D Models |

---

## Files Modified

- `/Users/grig/work/peermesh/repo/core-stack-test/README.md` - Complete rewrite

## Next Steps

1. Create individual pattern README files in `patterns/*/README.md`
2. Add docker-compose.yml with profile definitions
3. Create .env.example with all pattern variables
4. Implement test scripts in `tests/` directory
