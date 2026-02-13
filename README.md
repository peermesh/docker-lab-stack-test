# Core Stack Test

[![License: PolyForm Noncommercial](https://img.shields.io/badge/License-PolyForm%20Noncommercial-lightgrey.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/Docker-24%2B-blue)](https://docker.com)
[![Compose](https://img.shields.io/badge/Compose-v2-blue)](https://docs.docker.com/compose/)

Integration test bundle for [core](https://github.com/peermesh/core) infrastructure.

## Purpose

Validate security and completeness of the core boilerplate through:

- **Security tests** - TLS, secrets, permissions, network isolation
- **Integration tests** - Service connectivity, health checks, databases
- **Variation testing** - Different configuration combinations

---

## Patterns

10 self-hosted application patterns ready for deployment:

| Pattern | Service URL | Status | Description |
|---------|-------------|--------|-------------|
| [GoToSocial](#gotosocial) | `social.dockerlab.peermesh.org` | ![Ready](https://img.shields.io/badge/status-ready-green) | Lightweight ActivityPub social network |
| [WriteFreely](#writefreely) | `blog.dockerlab.peermesh.org` | ![Ready](https://img.shields.io/badge/status-ready-green) | Minimalist federated blogging platform |
| [PeerTube](#peertube) | `video.dockerlab.peermesh.org` | ![Ready](https://img.shields.io/badge/status-ready-green) | Decentralized video hosting with ActivityPub |
| [Listmonk](#listmonk) | `newsletter.dockerlab.peermesh.org` | ![Ready](https://img.shields.io/badge/status-ready-green) | Self-hosted newsletter and mailing list manager |
| [rss2bsky](#rss2bsky) | N/A (daemon) | ![Ready](https://img.shields.io/badge/status-ready-green) | RSS to Bluesky syndication bridge |
| [ActivityPods](#activitypods) | `pods.dockerlab.peermesh.org` | ![Ready](https://img.shields.io/badge/status-ready-green) | Solid pods with ActivityPub integration |
| [n8n](#n8n) | `automation.dockerlab.peermesh.org` | ![Ready](https://img.shields.io/badge/status-ready-green) | Workflow automation platform |
| [Pixelfed](#pixelfed) | `photos.dockerlab.peermesh.org` | ![Ready](https://img.shields.io/badge/status-ready-green) | Federated image sharing (Instagram alternative) |
| [Castopod](#castopod) | `podcast.dockerlab.peermesh.org` | ![Ready](https://img.shields.io/badge/status-ready-green) | Podcast hosting with ActivityPub |
| [Manyfold](#manyfold) | `models.dockerlab.peermesh.org` | ![Ready](https://img.shields.io/badge/status-ready-green) | 3D model library management |

---

## Quick Start

### Minimal Stack

Deploy core infrastructure only (Traefik, PostgreSQL, Redis):

```bash
git clone https://github.com/peermesh/core-stack-test
cd core-stack-test

cp .env.example .env
./scripts/generate-secrets.sh

# Minimal deployment (foundation + GoToSocial)
docker compose --profile traefik --profile gotosocial up -d
```

> **Note:** This repository includes a standalone foundation layer (`./foundation/`) 
> so it can run without the external `peer-mesh-docker-lab` dependency.

### Full Stack

Deploy all patterns with full monitoring:

```bash
git clone https://github.com/peermesh/core-stack-test
cd core-stack-test

cp .env.example .env
./scripts/generate-secrets.sh

# Full deployment (requires 8GB+ RAM)
docker compose --profile full up -d
```

### Single Pattern

Deploy a specific pattern:

```bash
# Example: GoToSocial only
docker compose --profile gotosocial up -d

# Example: WriteFreely only
docker compose --profile writefreely up -d
```

---

## Pattern Details

### GoToSocial

Lightweight ActivityPub social network server.

- **URL**: `https://social.dockerlab.peermesh.org`
- **Stack**: Go, SQLite/PostgreSQL
- **Resources**: 256MB RAM minimum
- **Docs**: [patterns/gotosocial/README.md](./patterns/gotosocial/README.md)

```bash
docker compose --profile gotosocial up -d
```

### WriteFreely

Minimalist, federated blogging platform.

- **URL**: `https://blog.dockerlab.peermesh.org`
- **Stack**: Go, SQLite/MySQL
- **Resources**: 128MB RAM minimum
- **Docs**: [patterns/writefreely/README.md](./patterns/writefreely/README.md)

```bash
docker compose --profile writefreely up -d
```

### PeerTube

Decentralized video hosting with ActivityPub federation.

- **URL**: `https://video.dockerlab.peermesh.org`
- **Stack**: Node.js, PostgreSQL, Redis
- **Resources**: 2GB RAM minimum
- **Docs**: [patterns/peertube/README.md](./patterns/peertube/README.md)

```bash
docker compose --profile peertube up -d
```

### Listmonk

High-performance newsletter and mailing list manager.

- **URL**: `https://newsletter.dockerlab.peermesh.org`
- **Stack**: Go, PostgreSQL
- **Resources**: 256MB RAM minimum
- **Docs**: [patterns/listmonk/README.md](./patterns/listmonk/README.md)

```bash
docker compose --profile listmonk up -d
```

### rss2bsky

RSS feed to Bluesky syndication daemon.

- **URL**: N/A (background daemon)
- **Stack**: Python
- **Resources**: 64MB RAM minimum
- **Docs**: [patterns/rss2bsky/README.md](./patterns/rss2bsky/README.md)

```bash
docker compose --profile rss2bsky up -d
```

### ActivityPods

Solid pods with ActivityPub integration for decentralized data.

- **URL**: `https://pods.dockerlab.peermesh.org`
- **Stack**: Node.js, MongoDB
- **Resources**: 512MB RAM minimum
- **Docs**: [patterns/activitypods/README.md](./patterns/activitypods/README.md)

```bash
docker compose --profile activitypods up -d
```

### n8n

Workflow automation platform (Zapier/IFTTT alternative).

- **URL**: `https://automation.dockerlab.peermesh.org`
- **Stack**: Node.js, PostgreSQL
- **Resources**: 512MB RAM minimum
- **Docs**: [patterns/n8n/README.md](./patterns/n8n/README.md)

```bash
docker compose --profile n8n up -d
```

### Pixelfed

Federated image sharing platform (Instagram alternative).

- **URL**: `https://photos.dockerlab.peermesh.org`
- **Stack**: PHP/Laravel, PostgreSQL, Redis
- **Resources**: 1GB RAM minimum
- **Docs**: [patterns/pixelfed/README.md](./patterns/pixelfed/README.md)

```bash
docker compose --profile pixelfed up -d
```

### Castopod

Podcast hosting platform with ActivityPub federation.

- **URL**: `https://podcast.dockerlab.peermesh.org`
- **Stack**: PHP, MySQL/MariaDB
- **Resources**: 512MB RAM minimum
- **Docs**: [patterns/castopod/README.md](./patterns/castopod/README.md)

```bash
docker compose --profile castopod up -d
```

### Manyfold

3D model library management for makers.

- **URL**: `https://models.dockerlab.peermesh.org`
- **Stack**: Ruby on Rails, PostgreSQL
- **Resources**: 512MB RAM minimum
- **Docs**: [patterns/manyfold/README.md](./patterns/manyfold/README.md)

```bash
docker compose --profile manyfold up -d
```

---

## VPS Deployment

### Requirements

- Docker 24+
- Docker Compose v2
- 4GB RAM minimum (8GB for full stack)
- Domain with DNS configured
- Ports 80, 443 open

### DNS Configuration

Point these subdomains to your VPS IP:

```
social.dockerlab.peermesh.org    -> YOUR_VPS_IP
blog.dockerlab.peermesh.org      -> YOUR_VPS_IP
video.dockerlab.peermesh.org     -> YOUR_VPS_IP
newsletter.dockerlab.peermesh.org -> YOUR_VPS_IP
pods.dockerlab.peermesh.org      -> YOUR_VPS_IP
automation.dockerlab.peermesh.org -> YOUR_VPS_IP
photos.dockerlab.peermesh.org    -> YOUR_VPS_IP
podcast.dockerlab.peermesh.org   -> YOUR_VPS_IP
models.dockerlab.peermesh.org    -> YOUR_VPS_IP
```

### Deployment Steps

```bash
# 1. SSH into VPS
ssh user@your-vps

# 2. Clone repository
git clone https://github.com/peermesh/core-stack-test
cd core-stack-test

# 3. Configure environment
cp .env.example .env
nano .env  # Update domain, email, etc.

# 4. Generate secrets
./scripts/generate-secrets.sh

# 5. Deploy
docker compose --profile full up -d

# 6. Verify deployment
./tests/run-all.sh
```

### TLS Certificates

Traefik handles automatic Let's Encrypt certificate provisioning:

```yaml
# In .env
ACME_EMAIL=admin@yourdomain.org
DOMAIN=dockerlab.peermesh.org
```

---

## Structure

```
core-stack-test/
├── docker-compose.yml    # Main stack definition
├── .env.example          # Configuration template
├── patterns/             # Pattern-specific configurations
│   ├── gotosocial/
│   ├── writefreely/
│   ├── peertube/
│   ├── listmonk/
│   ├── rss2bsky/
│   ├── activitypods/
│   ├── n8n/
│   ├── pixelfed/
│   ├── castopod/
│   └── manyfold/
├── variations/           # Alternative configurations
│   ├── minimal/          # Smallest testable bundle
│   └── full-stack/       # All services enabled
├── tests/                # Test scripts
│   ├── security/         # Security validation
│   └── integration/      # Service integration
└── docs/                 # Documentation
```

---

## Testing

### Run All Tests

```bash
./tests/run-all.sh
```

### Security Tests

```bash
./tests/security/tls-check.sh
./tests/security/secrets-scan.sh
./tests/security/permissions-check.sh
```

### Integration Tests

```bash
./tests/integration/health-checks.sh
./tests/integration/connectivity.sh
./tests/integration/database.sh
```

---

## Documentation

- [VISION.md](./VISION.md) - Project goals and principles
- [docs/TESTS.md](./docs/TESTS.md) - Test documentation
- [docs/VARIATIONS.md](./docs/VARIATIONS.md) - Configuration variations

---

## Related

- [peermesh/core](https://github.com/peermesh/core) - Base infrastructure

---

## License

Original source code and documentation in this repository are licensed under the **PolyForm Noncommercial License 1.0.0** ([`LICENSE`](LICENSE)). See [`COPYRIGHT`](COPYRIGHT), [`COMMERCIAL-LICENSE.md`](COMMERCIAL-LICENSE.md) for commercial use, [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md) for third-party components, and [`DEPENDENCY-LICENSE-POLICY.md`](DEPENDENCY-LICENSE-POLICY.md) for how project and dependency licenses interact.

Third-party components (including container images and upstream pattern applications) remain under their respective licenses; the project license does not replace them.
