# STATE-OF-PROJECT.md

**Project:** docker-lab-stack-test  
**Last Updated:** 2026-02-07 15:22 MST  
**Updated By:** Docker Lab Project Lead (subagent)

---

## Current Status

**Phase:** Active Development / Pre-Commit  
**Branch:** main (up to date with origin)  
**Last Commit:** 551e767 - `feat: update landing page with all 10 deployed services`

### Summary

Docker Lab Stack Test is a Docker Compose-based integration test bundle for validating PeerMesh's docker-lab infrastructure. It includes **10 production-ready self-hosted patterns** (Fediverse and federated services) deployable on commodity VPS infrastructure.

---

## Recent Work

### peer-mesh-specialist Sub-Agent (Earlier Today)
- **20 services validated** across the stack
- Foundation layer created for standalone operation (`./foundation/`)
- Database init scripts configured
- Network segmentation verified (proxy-external, db-internal, app-internal)

### Uncommitted Changes (5 files modified)
| File | Changes |
|------|---------|
| `.env.example` | +4/-1 lines |
| `README.md` | +7/-2 lines |
| `docker-compose.yml` | +31/-16 lines (simplified) |
| `docs/COMPOSE-ARCHITECTURE.md` | +18/-13 lines (simplified) |
| `scripts/generate-secrets.sh` | +2 lines |

### New Untracked Directories
- `.dev/` - AI development state
- `apps/` - Application-specific configs (n8n, rss2bsky symlink)
- `config/` - Configuration files
- `foundation/` - **Standalone foundation layer** (Traefik, PostgreSQL, MySQL, MongoDB, Redis, MinIO)
- `secrets/.gitignore` - Secrets placeholder

---

## Architecture Overview

```
docker-lab-stack-test/
├── foundation/           # Standalone infrastructure (new)
│   ├── docker-compose.yml
│   └── init-scripts/     # DB initialization
├── patterns/             # 10 application patterns
│   ├── activitypods/
│   ├── castopod/
│   ├── gotosocial/
│   ├── listmonk/
│   ├── manyfold/
│   ├── n8n/
│   ├── peertube/
│   ├── pixelfed/
│   ├── rss2bsky/
│   └── writefreely/
├── apps/                 # App-specific configs (new)
├── docker-compose.yml    # Main orchestration (1003 lines)
└── tests/                # Security & integration tests
```

### Service Matrix (All 10 Patterns Ready)

| Pattern | URL | Status | Stack |
|---------|-----|--------|-------|
| GoToSocial | social.dockerlab.peermesh.org | ✅ Ready | Go, SQLite |
| WriteFreely | blog.dockerlab.peermesh.org | ✅ Ready | Go, MySQL |
| PeerTube | video.dockerlab.peermesh.org | ✅ Ready | Node.js, PostgreSQL, Redis |
| Listmonk | newsletter.dockerlab.peermesh.org | ✅ Ready | Go, PostgreSQL |
| rss2bsky | N/A (daemon) | ✅ Ready | Python |
| ActivityPods | pods.dockerlab.peermesh.org | ✅ Ready | Node.js, MongoDB |
| n8n | automation.dockerlab.peermesh.org | ✅ Ready | Node.js, PostgreSQL |
| Pixelfed | photos.dockerlab.peermesh.org | ✅ Ready | PHP, PostgreSQL, Redis |
| Castopod | podcast.dockerlab.peermesh.org | ✅ Ready | PHP, MySQL |
| Manyfold | models.dockerlab.peermesh.org | ✅ Ready | Ruby, PostgreSQL |

---

## Next Actions Needed

### Immediate (Commit Pending)
1. **Review & commit current changes** - 5 modified files + new directories need to be staged
2. **Decide on `.dev/` tracking** - Should AI state files be committed or .gitignored?
3. **Add `foundation/` to git** - Critical new component for standalone operation
4. **Add `apps/` and `config/` to git** - New directories need tracking decisions

### Short-term
1. **Run integration tests** - `./tests/run-all.sh` to validate stack
2. **Test standalone mode** - Verify foundation layer works without external docker-lab
3. **Update COMPOSE-ARCHITECTURE.md** - Document new foundation include pattern
4. **Create AGENTS.md** - No project-specific agent instructions exist yet

### Medium-term
1. **VPS deployment test** - Deploy full stack to test infrastructure
2. **TLS validation** - Run security tests with real certificates
3. **Resource profiling** - Validate memory requirements (4GB minimum, 8GB full)

---

## Blockers / Decisions Needed

### 🔴 Blockers
*None identified*

### 🟡 Decisions Needed

1. **Git tracking for new directories**
   - `foundation/` - Should definitely be tracked (core infrastructure)
   - `.dev/` - Developer/AI state, typically .gitignored
   - `apps/` - Needs review (contains symlink)
   - `config/` - Needs review
   - `secrets/` - Only .gitignore should be tracked

2. **Commit strategy**
   - Single commit with all changes?
   - Separate commits for foundation vs. docs cleanup?

3. **CI/CD pipeline**
   - No GitHub Actions defined yet
   - Should tests run on PR/push?

---

## Previous Reviews

- **2026-01-12** - Full repository review completed (`.dev/ai/reviews/`)
  - 10 patterns documented
  - Architecture patterns identified
  - Build complexity assessed

---

## Notes for Future Agents

- Main compose file uses `include:` directive to import foundation
- `DOCKER_LAB_PATH` env var controls standalone vs external mode
- Database init scripts in `foundation/init-scripts/` run on first startup
- Traefik handles all TLS via Let's Encrypt ACME
- All secrets are file-based (never in environment variables)
