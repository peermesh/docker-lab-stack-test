# Test Scripts Documentation

This document describes the test scripts available for validating the docker-lab-stack-test project.

## Overview

The test suite is organized into two categories:

- **Security Tests**: Validate TLS configuration, secret management, and container permissions
- **Integration Tests**: Verify service health, connectivity, and database connections

## Quick Start

```bash
# Run all tests
./tests/run-all.sh

# Run individual test suites
./tests/security/tls-check.sh
./tests/security/secrets-scan.sh
./tests/security/permissions-check.sh
./tests/integration/health-checks.sh
./tests/integration/connectivity.sh
./tests/integration/database.sh
```

## Master Test Runner

### `tests/run-all.sh`

Orchestrates all test suites and produces a summary report.

**Features:**
- Runs all security and integration tests in sequence
- Tracks pass/fail/skip counts
- Provides colored output for easy reading
- Checks prerequisites (docker, curl, openssl)

**Exit Codes:**
- `0`: All tests passed
- `1`: One or more tests failed

---

## Security Tests

### `tests/security/tls-check.sh`

Verifies TLS certificates on all endpoints.

**Checks:**
- TLS is enabled on configured endpoints
- Certificates are valid and not expired
- Certificate chain is complete
- Internal certificate files are valid
- Container TLS configuration

**Environment Variables:**
| Variable | Description | Default |
|----------|-------------|---------|
| `TLS_ENDPOINTS` | Comma-separated list of endpoints to check (host:port) | None |
| `TLS_CHECK_EXPIRY_DAYS` | Warn if cert expires within N days | 30 |

**Example:**
```bash
TLS_ENDPOINTS="app.example.com:443,api.example.com:8443" ./tests/security/tls-check.sh
```

---

### `tests/security/secrets-scan.sh`

Scans the codebase for exposed secrets.

**Checks:**
- Hardcoded passwords and API keys
- Private keys and certificates
- Unprotected .env files
- Docker environment variable exposure
- GitHub tokens and API keys

**Environment Variables:**
| Variable | Description | Default |
|----------|-------------|---------|
| `PROJECT_ROOT` | Root directory to scan | Auto-detected |

**Patterns Detected:**
- Password assignments in code
- API key patterns (OpenAI, GitHub PAT, etc.)
- Private key files
- Sensitive configuration files

---

### `tests/security/permissions-check.sh`

Verifies container and file permissions.

**Checks:**
- Containers not running as root
- Privileged mode usage
- Capability restrictions
- File permissions on sensitive files
- Docker socket mounting
- Host network mode

**Environment Variables:**
| Variable | Description | Default |
|----------|-------------|---------|
| `PROJECT_ROOT` | Root directory to check | Auto-detected |

---

## Integration Tests

### `tests/integration/health-checks.sh`

Verifies all service health checks pass.

**Checks:**
- Docker container health status
- HTTP health endpoints
- Common health endpoint patterns
- Docker-compose service status

**Environment Variables:**
| Variable | Description | Default |
|----------|-------------|---------|
| `HTTP_TIMEOUT` | Timeout for HTTP health checks (seconds) | 5 |
| `HEALTH_ENDPOINTS` | Comma-separated health endpoints (name:url) | None |

**Example:**
```bash
HEALTH_ENDPOINTS="api:http://localhost:3000/health,web:http://localhost:8080/healthz" ./tests/integration/health-checks.sh
```

---

### `tests/integration/connectivity.sh`

Tests service-to-service connectivity.

**Checks:**
- Docker network configuration
- DNS resolution between containers
- Network connectivity between containers
- Custom connectivity tests
- External connectivity from containers

**Environment Variables:**
| Variable | Description | Default |
|----------|-------------|---------|
| `CONNECTIVITY_TESTS` | Custom tests (source:target:port) | None |

**Example:**
```bash
CONNECTIVITY_TESTS="web:api:3000,api:redis:6379" ./tests/integration/connectivity.sh
```

---

### `tests/integration/database.sh`

Tests database connections.

**Checks:**
- Database container health
- Auto-detected database connections (PostgreSQL, MySQL, MongoDB, Redis)
- Custom database connections
- App-to-database connectivity

**Supported Databases:**
- PostgreSQL
- MySQL/MariaDB
- MongoDB
- Redis

**Environment Variables:**
| Variable | Description | Default |
|----------|-------------|---------|
| `DB_CONNECTIONS` | Custom connections (type:host:port:db:user) | None |

**Example:**
```bash
DB_CONNECTIONS="postgres:localhost:5432:mydb:postgres,redis:localhost:6379" ./tests/integration/database.sh
```

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Test Suite

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Start services
        run: docker compose up -d

      - name: Wait for services
        run: sleep 30

      - name: Run tests
        run: ./tests/run-all.sh
        env:
          HEALTH_ENDPOINTS: "app:http://localhost:8080/health"
          TLS_ENDPOINTS: "localhost:443"
```

### Local Development

```bash
# Start your stack
docker compose up -d

# Wait for services to be ready
sleep 10

# Run full test suite
./tests/run-all.sh

# Or run specific tests
./tests/security/secrets-scan.sh
./tests/integration/health-checks.sh
```

---

## Output Format

All scripts use consistent colored output:

- `[PASS]` - Test passed (green)
- `[FAIL]` - Test failed (red)
- `[WARN]` - Warning, non-fatal issue (yellow)
- `[SKIP]` - Test skipped (yellow)

### Example Output

```
======================================
  Docker Lab Stack Test Suite
======================================

Started at: 2024-01-02 15:30:00

--- Prerequisites Check ---

  [OK] docker is available
  [OK] docker compose is available
  [OK] curl is available
  [OK] openssl is available

--- Security Tests ---

  Running: TLS Certificate Check... [PASS]
  Running: Secrets Scan... [PASS]
  Running: Permissions Check... [PASS]

--- Integration Tests ---

  Running: Health Checks... [PASS]
  Running: Service Connectivity... [PASS]
  Running: Database Connections... [PASS]

======================================
  Test Summary
======================================

Completed at: 2024-01-02 15:30:15

Results:
  Passed:  6
  Failed:  0
  Skipped: 0
  ─────────────
  Total:   6

All tests passed!
```

---

## Extending the Test Suite

### Adding a New Test Script

1. Create the script in the appropriate directory (`security/` or `integration/`)
2. Follow the existing pattern:
   - Use `#!/bin/bash` shebang
   - Set `set -euo pipefail`
   - Define color constants
   - Create `print_result` function
   - Exit with `0` on success, `1` on failure
3. Make it executable: `chmod +x tests/your-test.sh`
4. Add to `run-all.sh` if it should run automatically

### Test Script Template

```bash
#!/bin/bash
#
# your-test.sh - Description of your test
#

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

FAILURES=0

print_result() {
    local status="$1"
    local message="$2"
    case "$status" in
        pass) echo -e "  ${GREEN}[PASS]${NC} $message" ;;
        fail) echo -e "  ${RED}[FAIL]${NC} $message"; FAILURES=$((FAILURES + 1)) ;;
        skip) echo -e "  ${YELLOW}[SKIP]${NC} $message" ;;
    esac
}

main() {
    echo "Your Test Name"
    echo "=============="

    # Your test logic here
    print_result "pass" "Test passed"

    if [[ $FAILURES -gt 0 ]]; then
        exit 1
    fi
}

main "$@"
```

---

## Troubleshooting

### Tests Skip with "Docker not available"

Ensure Docker is installed and running:
```bash
docker version
docker compose version
```

### Health checks fail immediately

Services may need time to start. Add a wait:
```bash
docker compose up -d
sleep 30
./tests/run-all.sh
```

### TLS tests fail on localhost

The TLS tests require actual TLS endpoints. For local development without TLS:
```bash
TLS_ENDPOINTS="" ./tests/run-all.sh
```

### Database tests cannot connect

Ensure database containers are healthy and accessible:
```bash
docker ps
docker logs <database-container>
```
