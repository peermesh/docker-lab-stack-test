#!/bin/bash
#
# health-checks.sh - Verify all service health checks pass
#
# Checks:
# - Docker container health status
# - HTTP health endpoints
# - Service readiness
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

# Default timeout for HTTP checks (seconds)
HTTP_TIMEOUT="${HTTP_TIMEOUT:-5}"

# Custom health endpoints (can be set via environment)
# Format: "service_name:url,service_name:url"
HEALTH_ENDPOINTS="${HEALTH_ENDPOINTS:-}"

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

# Check Docker container health status
check_container_health() {
    echo ""
    echo "Checking Docker container health..."
    echo ""

    # Check if docker is available
    if ! command -v docker &> /dev/null; then
        print_result "skip" "Docker not available"
        return 0
    fi

    # Get all running containers
    local containers
    containers=$(docker ps --format "{{.Names}}" 2>/dev/null) || {
        print_result "skip" "Could not list containers"
        return 0
    }

    if [[ -z "$containers" ]]; then
        print_result "skip" "No running containers"
        return 0
    fi

    while IFS= read -r container; do
        # Get health status
        local health_status
        health_status=$(docker inspect "$container" --format '{{.State.Health.Status}}' 2>/dev/null) || health_status="no-healthcheck"

        case "$health_status" in
            "healthy")
                print_result "pass" "$container: healthy"
                ;;
            "unhealthy")
                print_result "fail" "$container: unhealthy"

                # Get last health check log
                local health_log
                health_log=$(docker inspect "$container" --format '{{range .State.Health.Log}}{{.Output}}{{end}}' 2>/dev/null | tail -1)
                if [[ -n "$health_log" ]]; then
                    echo "      Last check: $health_log"
                fi
                ;;
            "starting")
                print_result "warn" "$container: starting (health check pending)"
                ;;
            "no-healthcheck"|"")
                # Check if container is at least running
                local state
                state=$(docker inspect "$container" --format '{{.State.Status}}' 2>/dev/null)
                if [[ "$state" == "running" ]]; then
                    print_result "pass" "$container: running (no health check defined)"
                else
                    print_result "fail" "$container: $state"
                fi
                ;;
            *)
                print_result "warn" "$container: unknown status ($health_status)"
                ;;
        esac
    done <<< "$containers"
}

# Check HTTP health endpoints
check_http_endpoints() {
    echo ""
    echo "Checking HTTP health endpoints..."
    echo ""

    if [[ -z "$HEALTH_ENDPOINTS" ]]; then
        print_result "skip" "No HEALTH_ENDPOINTS configured"
        return 0
    fi

    # Check if curl is available
    if ! command -v curl &> /dev/null; then
        print_result "skip" "curl not available for HTTP checks"
        return 0
    fi

    IFS=',' read -ra endpoints <<< "$HEALTH_ENDPOINTS"
    for entry in "${endpoints[@]}"; do
        entry=$(echo "$entry" | xargs)  # Trim whitespace

        local service_name url
        if [[ "$entry" == *:* ]]; then
            service_name="${entry%%:*}"
            url="${entry#*:}"
        else
            service_name="endpoint"
            url="$entry"
        fi

        # Make HTTP request
        local http_code
        http_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout "$HTTP_TIMEOUT" "$url" 2>/dev/null) || http_code="000"

        case "$http_code" in
            200|201|204)
                print_result "pass" "$service_name: HTTP $http_code ($url)"
                ;;
            301|302|303|307|308)
                print_result "pass" "$service_name: HTTP $http_code redirect ($url)"
                ;;
            000)
                print_result "fail" "$service_name: Connection failed ($url)"
                ;;
            *)
                print_result "fail" "$service_name: HTTP $http_code ($url)"
                ;;
        esac
    done
}

# Check common health endpoint patterns
check_common_endpoints() {
    echo ""
    echo "Checking common health endpoint patterns..."
    echo ""

    # Check if curl is available
    if ! command -v curl &> /dev/null; then
        print_result "skip" "curl not available"
        return 0
    fi

    # Common localhost ports to check
    local common_ports=(
        "80"
        "443"
        "3000"
        "8080"
        "8000"
        "5000"
    )

    local found_services=0

    for port in "${common_ports[@]}"; do
        # Quick check if port is listening
        if timeout 1 bash -c "echo >/dev/tcp/localhost/$port" 2>/dev/null; then
            found_services=1

            # Try common health paths
            local health_paths=("/health" "/healthz" "/api/health" "/status" "/")
            local found_health=false

            for path in "${health_paths[@]}"; do
                local url="http://localhost:$port$path"
                local http_code
                http_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 2 "$url" 2>/dev/null) || continue

                if [[ "$http_code" =~ ^2 ]]; then
                    print_result "pass" "localhost:$port$path responds with HTTP $http_code"
                    found_health=true
                    break
                fi
            done

            if [[ "$found_health" == false ]]; then
                print_result "warn" "localhost:$port is open but no health endpoint found"
            fi
        fi
    done

    if [[ $found_services -eq 0 ]]; then
        print_result "skip" "No services found on common ports"
    fi
}

# Check docker-compose service health
check_compose_services() {
    echo ""
    echo "Checking docker-compose services..."
    echo ""

    # Check if docker compose is available
    if ! docker compose version &> /dev/null && ! command -v docker-compose &> /dev/null; then
        print_result "skip" "docker compose not available"
        return 0
    fi

    # Try to get compose project name from environment or detect
    local compose_cmd="docker compose"
    if ! docker compose version &> /dev/null; then
        compose_cmd="docker-compose"
    fi

    # Get services from compose (if compose file exists)
    local compose_file
    for f in "docker-compose.yml" "docker-compose.yaml" "compose.yml" "compose.yaml"; do
        if [[ -f "$f" ]]; then
            compose_file="$f"
            break
        fi
    done

    if [[ -z "${compose_file:-}" ]]; then
        print_result "skip" "No docker-compose file found in current directory"
        return 0
    fi

    # Get service status
    local services_status
    services_status=$($compose_cmd ps 2>/dev/null) || {
        print_result "skip" "Could not get compose status"
        return 0
    }

    # Parse output and check each service
    echo "$services_status" | tail -n +2 | while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            local service_name
            service_name=$(echo "$line" | awk '{print $1}')

            if echo "$line" | grep -qiE "up|running|healthy"; then
                print_result "pass" "Compose service: $service_name"
            elif echo "$line" | grep -qiE "exit|stopped|unhealthy"; then
                print_result "fail" "Compose service: $service_name"
            fi
        fi
    done
}

# Main execution
main() {
    echo "Health Checks"
    echo "============="
    echo ""

    check_container_health
    check_http_endpoints
    check_common_endpoints
    check_compose_services

    echo ""
    echo "============="
    echo "Summary:"
    echo "  Passed: $PASSED"
    echo "  Failed: $FAILURES"
    echo ""

    if [[ $FAILURES -gt 0 ]]; then
        echo -e "${RED}Health Checks: FAILED${NC}"
        exit $EXIT_FAILURE
    elif [[ $PASSED -eq 0 ]]; then
        echo -e "${YELLOW}Health Checks: No services to check${NC}"
        exit $EXIT_SUCCESS
    else
        echo -e "${GREEN}Health Checks: PASSED${NC}"
        exit $EXIT_SUCCESS
    fi
}

main "$@"
