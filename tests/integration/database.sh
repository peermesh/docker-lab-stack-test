#!/bin/bash
#
# database.sh - Test database connections
#
# Checks:
# - Database container health
# - Connection from application containers
# - Basic query execution
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Exit codes
EXIT_SUCCESS=0
EXIT_FAILURE=1

# Track results
FAILURES=0
PASSED=0

# Database connection settings (can be overridden via environment)
# Format: "type:host:port:database:user"
DB_CONNECTIONS="${DB_CONNECTIONS:-}"

# Common database container name patterns
DB_PATTERNS="postgres|mysql|mariadb|mongodb|mongo|redis|memcached|elasticsearch"

# Print result
print_result() {
    local status="$1"
    local message="$2"

    case "$status" in
        pass)
            echo -e "  ${GREEN}[PASS]${NC} $message"
            PASSED=$((PASSED + 1))
            ;;
        fail)
            echo -e "  ${RED}[FAIL]${NC} $message"
            FAILURES=$((FAILURES + 1))
            ;;
        warn)
            echo -e "  ${YELLOW}[WARN]${NC} $message"
            ;;
        skip)
            echo -e "  ${YELLOW}[SKIP]${NC} $message"
            ;;
    esac
}

# Detect database containers
detect_database_containers() {
    echo ""
    echo "Detecting database containers..."
    echo ""

    # Check if docker is available
    if ! command -v docker &> /dev/null; then
        print_result "skip" "Docker not available"
        return 0
    fi

    # Find containers matching database patterns
    local db_containers
    db_containers=$(docker ps --format "{{.Names}}:{{.Image}}" 2>/dev/null | grep -iE "$DB_PATTERNS") || true

    if [[ -z "$db_containers" ]]; then
        print_result "skip" "No database containers detected"
        return 0
    fi

    while IFS= read -r line; do
        local name image
        name="${line%%:*}"
        image="${line#*:}"

        # Get container health
        local health
        health=$(docker inspect "$name" --format '{{.State.Health.Status}}' 2>/dev/null) || health="unknown"

        local status
        status=$(docker inspect "$name" --format '{{.State.Status}}' 2>/dev/null) || status="unknown"

        if [[ "$health" == "healthy" ]]; then
            print_result "pass" "$name ($image): healthy"
        elif [[ "$status" == "running" ]]; then
            if [[ "$health" == "no-healthcheck" ]] || [[ -z "$health" ]]; then
                print_result "pass" "$name ($image): running (no health check)"
            else
                print_result "warn" "$name ($image): running, health=$health"
            fi
        else
            print_result "fail" "$name ($image): $status"
        fi
    done <<< "$db_containers"
}

# Test PostgreSQL connection
test_postgres() {
    local container="$1"
    local db="${2:-postgres}"
    local user="${3:-postgres}"

    echo "  Testing PostgreSQL: $container"

    # Try to run a simple query
    local result
    result=$(docker exec "$container" psql -U "$user" -d "$db" -c "SELECT 1;" 2>&1) || {
        print_result "fail" "$container: PostgreSQL query failed"
        return 1
    }

    if echo "$result" | grep -q "1"; then
        print_result "pass" "$container: PostgreSQL responds"
    else
        print_result "fail" "$container: Unexpected response"
    fi
}

# Test MySQL/MariaDB connection
test_mysql() {
    local container="$1"
    local db="${2:-mysql}"
    local user="${3:-root}"

    echo "  Testing MySQL/MariaDB: $container"

    # Try to run a simple query
    local result
    result=$(docker exec "$container" mysql -u "$user" -e "SELECT 1;" 2>&1) || {
        print_result "fail" "$container: MySQL query failed"
        return 1
    }

    if echo "$result" | grep -q "1"; then
        print_result "pass" "$container: MySQL responds"
    else
        print_result "fail" "$container: Unexpected response"
    fi
}

# Test MongoDB connection
test_mongodb() {
    local container="$1"

    echo "  Testing MongoDB: $container"

    # Try to run a simple command
    local result
    result=$(docker exec "$container" mongosh --eval "db.runCommand({ping:1})" 2>&1) || \
    result=$(docker exec "$container" mongo --eval "db.runCommand({ping:1})" 2>&1) || {
        print_result "fail" "$container: MongoDB command failed"
        return 1
    }

    if echo "$result" | grep -qiE "ok.*:.*1"; then
        print_result "pass" "$container: MongoDB responds"
    else
        print_result "fail" "$container: Unexpected response"
    fi
}

# Test Redis connection
test_redis() {
    local container="$1"

    echo "  Testing Redis: $container"

    # Try to ping Redis
    local result
    result=$(docker exec "$container" redis-cli PING 2>&1) || {
        print_result "fail" "$container: Redis ping failed"
        return 1
    }

    if echo "$result" | grep -qi "PONG"; then
        print_result "pass" "$container: Redis responds"
    else
        print_result "fail" "$container: Unexpected response"
    fi
}

# Test database connections automatically
test_auto_detect() {
    echo ""
    echo "Testing detected database connections..."
    echo ""

    # Check if docker is available
    if ! command -v docker &> /dev/null; then
        print_result "skip" "Docker not available"
        return 0
    fi

    # Find database containers
    local db_containers
    db_containers=$(docker ps --format "{{.Names}}:{{.Image}}" 2>/dev/null) || {
        print_result "skip" "Could not list containers"
        return 0
    }

    if [[ -z "$db_containers" ]]; then
        print_result "skip" "No running containers"
        return 0
    fi

    local tested=0

    while IFS= read -r line; do
        local name image
        name="${line%%:*}"
        image="${line#*:}"

        if echo "$image" | grep -qiE "postgres"; then
            tested=1
            test_postgres "$name"
        elif echo "$image" | grep -qiE "mysql|mariadb"; then
            tested=1
            test_mysql "$name"
        elif echo "$image" | grep -qiE "mongo"; then
            tested=1
            test_mongodb "$name"
        elif echo "$image" | grep -qiE "redis"; then
            tested=1
            test_redis "$name"
        fi
    done <<< "$db_containers"

    if [[ $tested -eq 0 ]]; then
        print_result "skip" "No supported database types found"
    fi
}

# Test custom database connections
test_custom_connections() {
    echo ""
    echo "Testing custom database connections..."
    echo ""

    if [[ -z "$DB_CONNECTIONS" ]]; then
        print_result "skip" "No DB_CONNECTIONS configured"
        return 0
    fi

    IFS=',' read -ra connections <<< "$DB_CONNECTIONS"
    for conn in "${connections[@]}"; do
        conn=$(echo "$conn" | xargs)  # Trim whitespace

        # Parse type:host:port:database:user
        local db_type host port database user
        IFS=':' read -r db_type host port database user <<< "$conn"

        if [[ -z "$db_type" ]] || [[ -z "$host" ]]; then
            print_result "warn" "Invalid connection format: $conn"
            continue
        fi

        echo "  Testing $db_type connection to $host:$port..."

        case "$db_type" in
            postgres|postgresql)
                if command -v psql &> /dev/null; then
                    PGPASSWORD="${PGPASSWORD:-}" psql -h "$host" -p "${port:-5432}" -U "${user:-postgres}" -d "${database:-postgres}" -c "SELECT 1;" &>/dev/null && \
                        print_result "pass" "$db_type://$host:$port" || \
                        print_result "fail" "$db_type://$host:$port"
                else
                    print_result "skip" "psql client not available"
                fi
                ;;
            mysql|mariadb)
                if command -v mysql &> /dev/null; then
                    mysql -h "$host" -P "${port:-3306}" -u "${user:-root}" -e "SELECT 1;" &>/dev/null && \
                        print_result "pass" "$db_type://$host:$port" || \
                        print_result "fail" "$db_type://$host:$port"
                else
                    print_result "skip" "mysql client not available"
                fi
                ;;
            redis)
                if command -v redis-cli &> /dev/null; then
                    redis-cli -h "$host" -p "${port:-6379}" PING &>/dev/null && \
                        print_result "pass" "$db_type://$host:$port" || \
                        print_result "fail" "$db_type://$host:$port"
                else
                    print_result "skip" "redis-cli not available"
                fi
                ;;
            *)
                print_result "skip" "Unsupported database type: $db_type"
                ;;
        esac
    done
}

# Check database connectivity from app containers
test_app_to_db_connectivity() {
    echo ""
    echo "Testing app-to-database connectivity..."
    echo ""

    # Check if docker is available
    if ! command -v docker &> /dev/null; then
        print_result "skip" "Docker not available"
        return 0
    fi

    # Get non-database containers
    local app_containers
    app_containers=$(docker ps --format "{{.Names}}:{{.Image}}" 2>/dev/null | grep -viE "$DB_PATTERNS" | head -3) || true

    # Get database containers
    local db_containers
    db_containers=$(docker ps --format "{{.Names}}" 2>/dev/null | grep -iE "$DB_PATTERNS") || true

    if [[ -z "$app_containers" ]] || [[ -z "$db_containers" ]]; then
        print_result "skip" "Need both app and database containers"
        return 0
    fi

    # Test connectivity from first app container to each database
    local app_name
    app_name=$(echo "$app_containers" | head -1 | cut -d: -f1)

    while IFS= read -r db_name; do
        # Get database container's exposed port
        local db_port
        db_port=$(docker inspect "$db_name" --format '{{range $p, $conf := .NetworkSettings.Ports}}{{$p}}{{"\n"}}{{end}}' 2>/dev/null | head -1 | cut -d/ -f1) || true

        if [[ -n "$db_port" ]]; then
            # Try to connect using nc or bash
            local result=""
            if docker exec "$app_name" which nc &>/dev/null; then
                docker exec "$app_name" nc -z -w 2 "$db_name" "$db_port" &>/dev/null && result="ok"
            elif docker exec "$app_name" timeout 2 bash -c "echo >/dev/tcp/$db_name/$db_port" &>/dev/null; then
                result="ok"
            fi

            if [[ -n "$result" ]]; then
                print_result "pass" "$app_name -> $db_name:$db_port"
            else
                print_result "fail" "$app_name -> $db_name:$db_port"
            fi
        fi
    done <<< "$db_containers"
}

# Main execution
main() {
    echo "Database Connection Tests"
    echo "========================="
    echo ""

    detect_database_containers
    test_auto_detect
    test_custom_connections
    test_app_to_db_connectivity

    echo ""
    echo "========================="
    echo "Summary:"
    echo "  Passed: $PASSED"
    echo "  Failed: $FAILURES"
    echo ""

    if [[ $FAILURES -gt 0 ]]; then
        echo -e "${RED}Database Tests: FAILED${NC}"
        exit $EXIT_FAILURE
    elif [[ $PASSED -eq 0 ]]; then
        echo -e "${YELLOW}Database Tests: No tests executed${NC}"
        exit $EXIT_SUCCESS
    else
        echo -e "${GREEN}Database Tests: PASSED${NC}"
        exit $EXIT_SUCCESS
    fi
}

main "$@"
