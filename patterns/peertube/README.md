# PeerTube Pattern

Decentralized video hosting platform with ActivityPub federation and P2P delivery.

## Quick Start

```bash
# Deploy PeerTube
docker compose --profile peertube up -d

# View logs
docker compose logs -f peertube
```

## Services

| Service | Purpose | Port |
|---------|---------|------|
| peertube | Main video platform | 9000 |
| peertube-redis | PeerTube's Redis cache | 6379 |

## Configuration

### Required Environment Variables

```bash
# Domain configuration
DOMAIN=example.com          # peertube.example.com

# Admin
ADMIN_EMAIL=admin@example.com

# Database (from foundation)
PEERTUBE_DB_PASSWORD=generated

# Secrets
PEERTUBE_SECRET=generated_256bit_secret
```

### Storage

PeerTube requires significant storage for video content:

- **Videos**: `/data` volume for transcoded videos
- **Config**: `/config` volume for settings and keys
- **Redis**: Dedicated Redis instance (not shared)

## Resource Requirements

| Profile | Memory | CPU | Storage |
|---------|--------|-----|---------|
| Minimum | 2GB | 2 cores | 50GB |
| Recommended | 4GB | 4 cores | 500GB |

## URLs

- **Main**: `https://peertube.${DOMAIN}`
- **API**: `https://peertube.${DOMAIN}/api/v1`

## Federation

PeerTube federates via ActivityPub with:

- Other PeerTube instances
- Mastodon (video previews)
- Pleroma
- Any ActivityPub-compatible service

## Transcoding

Videos are transcoded to multiple resolutions by default:

- 1080p, 720p, 480p, 360p, 240p
- HLS streaming support
- WebTorrent for P2P delivery

## Security Notes

- Runs as non-root user
- Requires PostgreSQL from foundation
- Uses dedicated Redis instance (network-isolated)
- TLS termination via Traefik
