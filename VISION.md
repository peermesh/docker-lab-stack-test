# Docker Lab Stack Test: Vision & Purpose

## What This Is

A test bundle (recipe) for validating the security and completeness of the [docker-lab](https://github.com/peermesh/docker-lab) infrastructure. This repository:

1. **Bundles tested patterns** from docker-lab into a deployable stack
2. **Validates security** through automated and manual testing
3. **Demonstrates completeness** of the boilerplate for real-world use
4. **Enables variations** to test different configuration combinations

---

## The Problem We're Solving

Docker Compose boilerplates need validation:

- Does the security configuration actually work?
- Do all services integrate correctly?
- Are there gaps in the documentation?
- Do the profiles combine properly?

This repository provides a structured way to test these questions.

---

## Core Principles

### 1. Test Real Deployments

Not synthetic tests - actual deployments with real services:

- Deploy the full stack
- Run security scans
- Validate service connectivity
- Test backup/restore flows

### 2. Alterable Variations

Support different test configurations:

```
variations/
├── minimal/        # Smallest testable bundle
├── full-stack/     # All services enabled
├── security-audit/ # Security-focused configuration
└── media-heavy/    # Media services (PeerTube, etc.)
```

### 3. Public and Reproducible

All tests should be:

- Runnable by anyone with Docker
- Documented with expected results
- Automated where possible

---

## What's Included

### Base Stack (from docker-lab)

| Component | Purpose |
|-----------|---------|
| Traefik | Reverse proxy, TLS |
| PostgreSQL | Primary database |
| Redis | Caching |
| Monitoring | Health checks |

### Test Applications

| Application | Tests |
|-------------|-------|
| Ghost | CMS integration, MySQL variant |
| PeerTube | Video platform, resource limits |
| Solid | Pod server, authentication |
| Matrix/Synapse | Real-time messaging |

### Test Categories

| Category | Focus |
|----------|-------|
| Security | TLS, secrets, permissions, network isolation |
| Integration | Service connectivity, health checks |
| Performance | Resource limits, startup times |
| Operations | Backup, restore, updates |

---

## Non-Negotiable Constraints

Inherited from docker-lab:

1. **Docker Compose only** - No Kubernetes
2. **Local-first** - Works offline
3. **Commodity VPS** - Runs on $20-50/mo servers
4. **Zero daily maintenance** - Automated operations
5. **Security by default** - No shortcuts

---

## Test Execution

### Quick Start

```bash
# Clone and deploy
git clone https://github.com/peermesh/docker-lab-stack-test
cd docker-lab-stack-test
cp .env.example .env
./scripts/generate-secrets.sh
docker compose up -d

# Run tests
./tests/security/run-all.sh
./tests/integration/run-all.sh
```

### Security Tests

```bash
# TLS validation
./tests/security/tls-check.sh

# Secret exposure scan
./tests/security/secrets-scan.sh

# Container permissions
./tests/security/permissions-check.sh
```

### Integration Tests

```bash
# Health check validation
./tests/integration/health-checks.sh

# Service connectivity
./tests/integration/connectivity.sh

# Database connections
./tests/integration/database.sh
```

---

## Relationship to docker-lab

```
peermesh/docker-lab (infrastructure)
         │
         ▼
peermesh/docker-lab-stack-test (this repo)
         │
         ├── Tests security
         ├── Tests integration
         ├── Tests completeness
         └── Validates for production
```

This repo imports from docker-lab, doesn't duplicate.

---

## Success Criteria

### Security

- [ ] All secrets properly generated (no defaults)
- [ ] TLS working on all public endpoints
- [ ] No exposed ports beyond intended
- [ ] Container permissions restricted
- [ ] Network isolation enforced

### Integration

- [ ] All services start successfully
- [ ] Health checks pass
- [ ] Services can communicate as designed
- [ ] Backup/restore works

### Documentation

- [ ] All tests documented
- [ ] Failure modes explained
- [ ] Variations documented

---

## License

MIT License - Same as docker-lab

---

*Vision established: 2026-01-03*
