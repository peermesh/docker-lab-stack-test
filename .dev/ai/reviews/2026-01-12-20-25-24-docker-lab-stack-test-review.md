# Repository Review: docker-lab-stack-test

**Date**: 2026-01-12T20:25:24.844487
**Commit**: 551e7672ef6f92cdb4a65a67657e6448285fd6ab
**Branch**: main
**Trigger**: forced
**Template**: patterns v2.1.0
**Model**: sonnet

---

Now I have enough information to complete the review. Let me generate the structured review.

---

### Summary

docker-lab-stack-test is a Docker Compose-based integration test bundle that validates the security and completeness of the PeerMesh docker-lab infrastructure foundation. It provides ten production-ready self-hosted application patterns (GoToSocial, WriteFreely, PeerTube, Listmonk, rss2bsky, ActivityPods, n8n, Pixelfed, Castopod, Manyfold) for deploying Fediverse and federated services on commodity VPS infrastructure. The project emphasizes security testing, profile-based deployment variations, and validation of real-world integration patterns.

### Technical Overview

- **Primary Language**: YAML (Docker Compose), Shell (Bash)
- **Frameworks**: Docker Compose v2, Traefik, Docker
- **Architecture**: Microservice (containerized services with shared infrastructure)
- **Runtime**: Docker 24+, various containerized runtimes (Go, Node.js, PHP, Python, Ruby)
- **Data Storage**: PostgreSQL 16, MySQL 8.0, Redis 7, MongoDB 6.0, SQLite, Apache Jena Fuseki

### Architectural Patterns

- **Service Mesh via Reverse Proxy**: Traefik handles TLS termination, routing, and certificate management for all services
- **Profile-Based Composition**: Docker Compose profiles enable selective service activation (minimal, fediverse, full)
- **File-Based Secrets Management**: All credentials stored as files mounted into containers, never in environment variables
- **Network Segmentation**: Isolated networks (proxy-external, db-internal, app-internal) enforce security boundaries
- **Resource Constraints**: YAML anchors define reusable resource limit templates (small/medium/large)
- **Include Directive Pattern**: Foundation layer imported from external docker-lab repository via compose include
- **Health Check Protocol**: Standardized healthcheck definitions with configurable intervals and retry logic
- **Multi-Database Strategy**: Applications choose appropriate databases (PostgreSQL, MySQL, SQLite, Fuseki) based on requirements

### Module Decomposition

### Traefik Reverse Proxy
- **Responsibility**: Routes HTTPS traffic to services, handles TLS certificates, provides ingress
- **Component Role**: Module
- **Capability Family**: Infrastructure
- **Capability Verbs**: routing.proxy, tls.terminate, discovery.acme
- **Integration Facet**: Protocol (HTTPS, ACME/Let's Encrypt)
- **Interop Surfaces**: API, Ops
- **Build Complexity**: 1 (pre-built image with label-based config)
- **Key Files**: docker-compose.yml (labels), foundation from docker-lab
- **Dependencies**: Docker Socket Proxy, Let's Encrypt

### PostgreSQL Database
- **Responsibility**: Provides relational database for PeerTube, Listmonk, n8n, Manyfold
- **Component Role**: Module
- **Capability Family**: Infrastructure
- **Capability Verbs**: data.store, data.query
- **Integration Facet**: None
- **Interop Surfaces**: Data, API
- **Build Complexity**: 1 (managed by foundation)
- **Key Files**: Foundation docker-lab
- **Dependencies**: Docker volumes

### MySQL Database
- **Responsibility**: Provides relational database for WriteFreely, Pixelfed, Castopod
- **Component Role**: Module
- **Capability Family**: Infrastructure
- **Capability Verbs**: data.store, data.query
- **Integration Facet**: None
- **Interop Surfaces**: Data, API
- **Build Complexity**: 1 (managed by foundation)
- **Key Files**: Foundation docker-lab
- **Dependencies**: Docker volumes

### Redis Cache
- **Responsibility**: Provides caching and session storage for multiple applications
- **Component Role**: Module
- **Capability Family**: Infrastructure
- **Capability Verbs**: data.cache, queue.enqueue
- **Integration Facet**: None
- **Interop Surfaces**: Data, API
- **Build Complexity**: 1 (managed by foundation)
- **Key Files**: Foundation docker-lab
- **Dependencies**: Docker volumes

### GoToSocial
- **Responsibility**: Lightweight ActivityPub microblogging server (Mastodon alternative)
- **Component Role**: App
- **Capability Family**: Messaging & Social Graph
- **Capability Verbs**: social.post, social.follow, federation.activitypub
- **Integration Facet**: Protocol (ActivityPub)
- **Interop Surfaces**: UI, API, Federation
- **Build Complexity**: 2 (pre-built Go binary with file-based config)
- **Key Files**: docker-compose.yml:109-159, patterns/gotosocial/
- **Dependencies**: SQLite (embedded), Traefik

### WriteFreely
- **Responsibility**: Minimalist federated blogging platform
- **Component Role**: App
- **Capability Family**: Messaging & Social Graph
- **Capability Verbs**: content.publish, federation.activitypub
- **Integration Facet**: Protocol (ActivityPub)
- **Interop Surfaces**: UI, API, Federation
- **Build Complexity**: 2 (pre-built Go app with MySQL integration)
- **Key Files**: docker-compose.yml:166-221, patterns/writefreely/
- **Dependencies**: MySQL, Traefik

### PeerTube
- **Responsibility**: Decentralized video hosting with P2P delivery and federation
- **Component Role**: App
- **Capability Family**: Media & Live
- **Capability Verbs**: video.upload, video.stream, federation.activitypub
- **Integration Facet**: Protocol (ActivityPub, WebTorrent)
- **Interop Surfaces**: UI, API, Federation
- **Build Complexity**: 4 (complex Node.js app with PostgreSQL, Redis, transcoding requirements)
- **Key Files**: docker-compose.yml:228-316, patterns/peertube/
- **Dependencies**: PostgreSQL, Redis (dedicated), Traefik

### Listmonk
- **Responsibility**: Newsletter and mailing list management
- **Component Role**: App
- **Capability Family**: Messaging & Social Graph
- **Capability Verbs**: email.send, subscriber.manage, campaign.create
- **Integration Facet**: Service (SMTP)
- **Interop Surfaces**: UI, API
- **Build Complexity**: 2 (Go app with PostgreSQL backend)
- **Key Files**: docker-compose.yml:323-376, patterns/listmonk/
- **Dependencies**: PostgreSQL, SMTP server, Traefik

### rss2bsky
- **Responsibility**: RSS feed syndication to Bluesky (AT Protocol)
- **Component Role**: Module
- **Capability Family**: Federation / Protocol Bridges
- **Capability Verbs**: syndication.crossPost, feed.parse
- **Integration Facet**: Protocol (AT Protocol/Bluesky)
- **Interop Surfaces**: API, Federation
- **Build Complexity**: 2 (Python cron daemon with API integration)
- **Key Files**: docker-compose.yml:383-421, patterns/rss2bsky/
- **Dependencies**: Bluesky API

### ActivityPods (Fuseki + Backend + Frontend)
- **Responsibility**: Solid protocol pods with ActivityPub integration for decentralized data
- **Component Role**: App
- **Capability Family**: Data Export & Portability
- **Capability Verbs**: data.store, identity.authenticate, federation.activitypub, federation.solid
- **Integration Facet**: Protocol (ActivityPub, Solid)
- **Interop Surfaces**: UI, API, Federation, Data, Identity
- **Build Complexity**: 5 (complex multi-service stack: Fuseki triplestore, Node.js backend, React frontend)
- **Key Files**: docker-compose.yml:428-569, patterns/activitypods/
- **Dependencies**: Apache Jena Fuseki, Redis, SMTP, Traefik

### n8n
- **Responsibility**: Workflow automation platform for POSSE syndication and integrations
- **Component Role**: App
- **Capability Family**: Assistant / Agent
- **Capability Verbs**: workflow.execute, integration.connect
- **Integration Facet**: Service (multiple APIs via workflow nodes)
- **Interop Surfaces**: UI, API, Events
- **Build Complexity**: 3 (Node.js app with PostgreSQL, extensive integration surface)
- **Key Files**: docker-compose.yml:576-638, patterns/n8n/
- **Dependencies**: PostgreSQL, Traefik

### Pixelfed
- **Responsibility**: Federated image sharing (Instagram alternative)
- **Component Role**: App
- **Capability Family**: Media & Live
- **Capability Verbs**: image.upload, image.share, federation.activitypub
- **Integration Facet**: Protocol (ActivityPub)
- **Interop Surfaces**: UI, API, Federation
- **Build Complexity**: 4 (PHP/Laravel with MySQL, Redis, queue workers, image processing)
- **Key Files**: docker-compose.yml:645-768, patterns/pixelfed/
- **Dependencies**: MySQL, Redis, Traefik, Pixelfed-Worker

### Castopod
- **Responsibility**: Podcast hosting with ActivityPub and Podcasting 2.0 features
- **Component Role**: App
- **Capability Family**: Media & Live
- **Capability Verbs**: podcast.publish, federation.activitypub
- **Integration Facet**: Protocol (ActivityPub, RSS, Podcasting 2.0)
- **Interop Surfaces**: UI, API, Federation
- **Build Complexity**: 3 (PHP app with MySQL, Redis, media handling)
- **Key Files**: docker-compose.yml:775-840, patterns/castopod/
- **Dependencies**: MySQL, Redis, SMTP, Traefik

### Manyfold
- **Responsibility**: 3D model library management with ActivityPub federation
- **Component Role**: App
- **Capability Family**: Rights & Metadata
- **Capability Verbs**: asset.catalog, federation.activitypub
- **Integration Facet**: Protocol (ActivityPub)
- **Interop Surfaces**: UI, API, Federation
- **Build Complexity**: 3 (Ruby on Rails with PostgreSQL, Redis, 3D file processing)
- **Key Files**: docker-compose.yml:847-906, patterns/manyfold/
- **Dependencies**: PostgreSQL, Redis, Traefik

### Secret Generator
- **Responsibility**: Generates and manages all application secrets securely
- **Component Role**: Module
- **Capability Family**: Identity & Keys
- **Capability Verbs**: key.generate, secret.store
- **Integration Facet**: None
- **Interop Surfaces**: Ops
- **Build Complexity**: 1 (simple shell script using openssl)
- **Key Files**: scripts/generate-secrets.sh
- **Dependencies**: OpenSSL

### Test Suite (Security)
- **Responsibility**: Validates TLS configuration, secret exposure, container permissions
- **Component Role**: Module
- **Capability Family**: Infrastructure
- **Capability Verbs**: security.audit, compliance.check
- **Integration Facet**: None
- **Interop Surfaces**: Ops
- **Build Complexity**: 2 (bash scripts with curl/openssl checks)
- **Key Files**: tests/security/*.sh
- **Dependencies**: curl, openssl, docker CLI

### Test Suite (Integration)
- **Responsibility**: Validates service connectivity, health checks, database connections
- **Component Role**: Module
- **Capability Family**: Infrastructure
- **Capability Verbs**: integration.test, health.verify
- **Integration Facet**: None
- **Interop Surfaces**: Ops
- **Build Complexity**: 2 (bash scripts with docker/curl commands)
- **Key Files**: tests/integration/*.sh, tests/run-all.sh
- **Dependencies**: docker CLI, curl

### Popularity Metrics

| Metric | Value | Source |
|--------|-------|--------|
| GitHub Stars | 0 | GitHub |
| GitHub Forks | 0 | GitHub |
| Last Commit | 2026-01-03 | GitHub |
| Open Issues | 0 | GitHub |

### Implementation Mapping

### Traefik Reverse Proxy Implementation

**Open Source Alternatives**:
- [Traefik](https://github.com/traefik/traefik) - Cloud-native proxy with automatic HTTPS, Apache 2.0, 50k+ stars
- [Caddy](https://github.com/caddyserver/caddy) - Auto-HTTPS web server, Apache 2.0, 57k+ stars
- [Nginx Proxy Manager](https://github.com/NginxProxyManager/nginx-proxy-manager) - Web UI for nginx reverse proxy, MIT

**API Service Alternatives**:
- Cloudflare Tunnel - Free tier, managed edge routing
- AWS Application Load Balancer - Pay per use, AWS ecosystem

**Build Recommendation**:
- For MVP: Traefik (automatic Let's Encrypt, label-based config)
- For Scale: Cloudflare + origin server (DDoS protection, global CDN)
- For Control: Caddy (simpler config, automatic HTTPS)

### ActivityPub Federation Implementation

**Open Source Alternatives**:
- [Mastodon](https://github.com/mastodon/mastodon) - Full-featured microblogging, AGPLv3, 47k+ stars
- [GoToSocial](https://github.com/superseriousbusiness/gotosocial) - Lightweight ActivityPub, AGPLv3, 3.7k stars
- [Lemmy](https://github.com/LemmyNet/lemmy) - Federated link aggregator, AGPLv3, 13k+ stars

**API Service Alternatives**:
- Mastodon.social - Hosted Mastodon instance
- ActivityPub.rocks - Testing/validation service

**Build Recommendation**:
- For MVP: GoToSocial (50-100MB RAM, simple deployment)
- For Scale: Mastodon (mature, feature-rich, large community)
- For Control: Custom ActivityPub server with activitypub-express library

### PostgreSQL Database Implementation

**Open Source Alternatives**:
- [PostgreSQL](https://github.com/postgres/postgres) - Industry-standard relational DB, PostgreSQL License
- [CockroachDB](https://github.com/cockroachdb/cockroach) - Distributed PostgreSQL-compatible, BSL/Apache
- [TimescaleDB](https://github.com/timescale/timescaledb) - PostgreSQL extension for time-series, Apache 2.0

**API Service Alternatives**:
- Supabase - Managed PostgreSQL with realtime features, free tier generous
- Neon - Serverless PostgreSQL with autoscaling, free tier available
- AWS RDS PostgreSQL - Managed PostgreSQL, pay per use

**Build Recommendation**:
- For MVP: Managed PostgreSQL container (docker-lab foundation)
- For Scale: Supabase or AWS RDS (managed backups, scaling)
- For Control: Self-hosted PostgreSQL with pgBackRest

### Video Streaming (PeerTube) Implementation

**Open Source Alternatives**:
- [PeerTube](https://github.com/Chocobozzz/PeerTube) - Decentralized video platform, AGPLv3, 13k+ stars
- [MediaCMS](https://github.com/mediacms-io/mediacms) - Video sharing platform, AGPLv3, 2.8k stars
- [Owncast](https://github.com/owncast/owncast) - Self-hosted live streaming, MIT, 9.3k stars

**API Service Alternatives**:
- Livepeer - Decentralized video transcoding/streaming
- Mux - Video infrastructure API, $20/mo starting tier
- Cloudflare Stream - $1/1000 minutes viewed

**Build Recommendation**:
- For MVP: Owncast (simpler, live-only) or MediaCMS (lighter weight)
- For Scale: PeerTube with CDN/P2P delivery (bandwidth distribution)
- For Control: Custom HLS server with ffmpeg transcoding

### Newsletter/Email Campaign Implementation

**Open Source Alternatives**:
- [Listmonk](https://github.com/knadh/listmonk) - High-performance newsletter manager, AGPLv3, 15k+ stars
- [Mautic](https://github.com/mautic/mautic) - Marketing automation platform, GPL, 7k+ stars
- [Mailtrain](https://github.com/Mailtrain-org/mailtrain) - Self-hosted newsletter app, GPL

**API Service Alternatives**:
- Mailchimp - Free tier to 500 contacts, $13/mo after
- ConvertKit - Creator-focused, $25/mo for 1k subscribers
- SendGrid - Free tier 100 emails/day, pay-as-you-go

**Build Recommendation**:
- For MVP: Listmonk (lightweight, PostgreSQL-based)
- For Scale: SendGrid or Mailchimp (deliverability optimization)
- For Control: Listmonk + dedicated IP + DKIM/SPF

### Workflow Automation (n8n) Implementation

**Open Source Alternatives**:
- [n8n](https://github.com/n8n-io/n8n) - Workflow automation, Sustainable Use License, 47k+ stars
- [Activepieces](https://github.com/activepieces/activepieces) - No-code automation, MIT, 10k+ stars
- [Huginn](https://github.com/huginn/huginn) - Agent-based automation, MIT, 43k+ stars

**API Service Alternatives**:
- Zapier - $20/mo for 750 tasks
- Make (Integromat) - $9/mo for 10k operations
- n8n Cloud - Managed n8n, $20/mo starter

**Build Recommendation**:
- For MVP: n8n self-hosted (most integrations, active community)
- For Scale: n8n Cloud or Zapier (managed infrastructure)
- For Control: n8n self-hosted with PostgreSQL persistence

### Solid Protocol Pods (ActivityPods) Implementation

**Open Source Alternatives**:
- [ActivityPods](https://github.com/assemblee-virtuelle/activitypods) - Solid+ActivityPub integration, Apache 2.0
- [Community Solid Server](https://github.com/CommunitySolidServer/CommunitySolidServer) - TypeScript Solid server, MIT, 1.7k stars
- [Node Solid Server](https://github.com/nodeSolidServer/node-solid-server) - Reference implementation, MIT

**API Service Alternatives**:
- Inrupt PodSpaces - Commercial Solid hosting
- solidcommunity.net - Community Solid pods

**Build Recommendation**:
- For MVP: Community Solid Server (simpler, TypeScript-based)
- For Scale: ActivityPods (dual protocol support, federation)
- For Control: Custom Solid server with specific access control patterns

### Maturity Level

**beta**: Feature complete for intended use case (test bundle), actively developed, API (compose structure) may evolve but core patterns are stable.

### Tags

docker-compose, fediverse, activitypub, self-hosted, testing, security-validation, infrastructure-as-code, multi-service, reverse-proxy, microservices, integration-testing

### Metadata JSON

```json
{
  "target": "docker-lab-stack-test",
  "version": "2.1.0",
  "patterns": [
    "Service Mesh via Reverse Proxy",
    "Profile-Based Composition",
    "File-Based Secrets Management",
    "Network Segmentation",
    "Resource Constraints",
    "Include Directive Pattern",
    "Health Check Protocol",
    "Multi-Database Strategy"
  ],
  "components": [
    {
      "name": "Traefik Reverse Proxy",
      "component_role": "module",
      "capability_family": "infrastructure",
      "capability_verbs": ["routing.proxy", "tls.terminate", "discovery.acme"],
      "integration_facet": "protocol",
      "interop_surfaces": ["api", "ops"],
      "build_complexity": 1,
      "build_complexity_label": "Simple"
    },
    {
      "name": "PostgreSQL Database",
      "component_role": "module",
      "capability_family": "infrastructure",
      "capability_verbs": ["data.store", "data.query"],
      "integration_facet": "none",
      "interop_surfaces": ["data", "api"],
      "build_complexity": 1,
      "build_complexity_label": "Simple"
    },
    {
      "name": "MySQL Database",
      "component_role": "module",
      "capability_family": "infrastructure",
      "capability_verbs": ["data.store", "data.query"],
      "integration_facet": "none",
      "interop_surfaces": ["data", "api"],
      "build_complexity": 1,
      "build_complexity_label": "Simple"
    },
    {
      "name": "Redis Cache",
      "component_role": "module",
      "capability_family": "infrastructure",
      "capability_verbs": ["data.cache", "queue.enqueue"],
      "integration_facet": "none",
      "interop_surfaces": ["data", "api"],
      "build_complexity": 1,
      "build_complexity_label": "Simple"
    },
    {
      "name": "GoToSocial",
      "component_role": "app",
      "capability_family": "messaging-social-graph",
      "capability_verbs": ["social.post", "social.follow", "federation.activitypub"],
      "integration_facet": "protocol",
      "interop_surfaces": ["ui", "api", "federation"],
      "build_complexity": 2,
      "build_complexity_label": "Low"
    },
    {
      "name": "WriteFreely",
      "component_role": "app",
      "capability_family": "messaging-social-graph",
      "capability_verbs": ["content.publish", "federation.activitypub"],
      "integration_facet": "protocol",
      "interop_surfaces": ["ui", "api", "federation"],
      "build_complexity": 2,
      "build_complexity_label": "Low"
    },
    {
      "name": "PeerTube",
      "component_role": "app",
      "capability_family": "media-live",
      "capability_verbs": ["video.upload", "video.stream", "federation.activitypub"],
      "integration_facet": "protocol",
      "interop_surfaces": ["ui", "api", "federation"],
      "build_complexity": 4,
      "build_complexity_label": "Complex"
    },
    {
      "name": "Listmonk",
      "component_role": "app",
      "capability_family": "messaging-social-graph",
      "capability_verbs": ["email.send", "subscriber.manage", "campaign.create"],
      "integration_facet": "service",
      "interop_surfaces": ["ui", "api"],
      "build_complexity": 2,
      "build_complexity_label": "Low"
    },
    {
      "name": "rss2bsky",
      "component_role": "module",
      "capability_family": "federation-protocol-bridges",
      "capability_verbs": ["syndication.crossPost", "feed.parse"],
      "integration_facet": "protocol",
      "interop_surfaces": ["api", "federation"],
      "build_complexity": 2,
      "build_complexity_label": "Low"
    },
    {
      "name": "ActivityPods",
      "component_role": "app",
      "capability_family": "data-export-portability",
      "capability_verbs": ["data.store", "identity.authenticate", "federation.activitypub", "federation.solid"],
      "integration_facet": "protocol",
      "interop_surfaces": ["ui", "api", "federation", "data", "identity"],
      "build_complexity": 5,
      "build_complexity_label": "Very Complex"
    },
    {
      "name": "n8n",
      "component_role": "app",
      "capability_family": "assistant-agent",
      "capability_verbs": ["workflow.execute", "integration.connect"],
      "integration_facet": "service",
      "interop_surfaces": ["ui", "api", "events"],
      "build_complexity": 3,
      "build_complexity_label": "Medium"
    },
    {
      "name": "Pixelfed",
      "component_role": "app",
      "capability_family": "media-live",
      "capability_verbs": ["image.upload", "image.share", "federation.activitypub"],
      "integration_facet": "protocol",
      "interop_surfaces": ["ui", "api", "federation"],
      "build_complexity": 4,
      "build_complexity_label": "Complex"
    },
    {
      "name": "Castopod",
      "component_role": "app",
      "capability_family": "media-live",
      "capability_verbs": ["podcast.publish", "federation.activitypub"],
      "integration_facet": "protocol",
      "interop_surfaces": ["ui", "api", "federation"],
      "build_complexity": 3,
      "build_complexity_label": "Medium"
    },
    {
      "name": "Manyfold",
      "component_role": "app",
      "capability_family": "rights-metadata",
      "capability_verbs": ["asset.catalog", "federation.activitypub"],
      "integration_facet": "protocol",
      "interop_surfaces": ["ui", "api", "federation"],
      "build_complexity": 3,
      "build_complexity_label": "Medium"
    },
    {
      "name": "Secret Generator",
      "component_role": "module",
      "capability_family": "identity-keys",
      "capability_verbs": ["key.generate", "secret.store"],
      "integration_facet": "none",
      "interop_surfaces": ["ops"],
      "build_complexity": 1,
      "build_complexity_label": "Simple"
    },
    {
      "name": "Test Suite Security",
      "component_role": "module",
      "capability_family": "infrastructure",
      "capability_verbs": ["security.audit", "compliance.check"],
      "integration_facet": "none",
      "interop_surfaces": ["ops"],
      "build_complexity": 2,
      "build_complexity_label": "Low"
    },
    {
      "name": "Test Suite Integration",
      "component_role": "module",
      "capability_family": "infrastructure",
      "capability_verbs": ["integration.test", "health.verify"],
      "integration_facet": "none",
      "interop_surfaces": ["ops"],
      "build_complexity": 2,
      "build_complexity_label": "Low"
    }
  ],
  "tech_stack": [
    "Docker Compose",
    "Traefik",
    "PostgreSQL",
    "MySQL",
    "Redis",
    "Go",
    "Node.js",
    "PHP",
    "Python",
    "Ruby",
    "ActivityPub",
    "Solid Protocol"
  ],
  "integrations": [
    {
      "name": "ActivityPub",
      "facet": "protocol",
      "purpose": "Federated social networking protocol"
    },
    {
      "name": "Solid Protocol",
      "facet": "protocol",
      "purpose": "Decentralized data ownership"
    },
    {
      "name": "AT Protocol (Bluesky)",
      "facet": "protocol",
      "purpose": "RSS syndication to Bluesky"
    },
    {
      "name": "Let's Encrypt ACME",
      "facet": "protocol",
      "purpose": "Automatic TLS certificate provisioning"
    },
    {
      "name": "SMTP",
      "facet": "service",
      "purpose": "Email delivery for notifications and newsletters"
    },
    {
      "name": "WebTorrent",
      "facet": "protocol",
      "purpose": "P2P video delivery for PeerTube"
    }
  ],
  "overall_complexity": 3,
  "overall_complexity_label": "Medium",
  "popularity": {
    "github_stars": 0,
    "github_forks": 0,
    "last_commit": "2026-01-03",
    "open_issues": 0,
    "data_source": "github"
  },
  "maturity": "beta",
  "af_level": "AF3"
}
```
