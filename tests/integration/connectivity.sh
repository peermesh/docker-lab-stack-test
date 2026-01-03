#!/bin/bash
#
# connectivity.sh - Test service-to-service connectivity
#
# Checks:
# - Network connectivity between containers
# - DNS resolution within Docker network
# - Port accessibility between services
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

# Custom connectivity tests (can be set via environment)
# Format: "source_container:target_host:port,source:target:port"
CONNECTIVITY_TESTS="${CONNECTIVITY_TESTS:-}"

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

# Check Docker network configuration
check_docker_networks() {
    echo ""
    echo "Checking Docker networks..."
    echo ""

    # Check if docker is available
    if ! command -v docker &> /dev/null; then
        print_result "skip" "Docker not available"
        return 0
    fi

    # List networks (excluding default ones)
    local networks
    networks=$(docker network ls --format "{{.Name}}" 2>/dev/null | grep -vE "^(bridge|host|none)$") || true

    if [[ -z "$networks" ]]; then
        print_result "skip" "No custom networks found"
        return 0
    fi

    while IFS= read -r network; do
        # Get containers attached to this network
        local containers
        containers=$(docker network inspect "$network" --format '{{range .Containers}}{{.Name}} {{end}}' 2>/dev/null) || continue

        containers=$(echo "$containers" | xargs)  # Trim

        if [[ -n "$containers" ]]; then
            print_result "pass" "Network '$network': $containers"
        else
            print_result "warn" "Network '$network': no containers attached"
        fi
    done <<< "$networks"
}

# Test DNS resolution between containers
check_container_dns() {
    echo ""
    echo "Checking container DNS resolution..."
    echo ""

    # Check if docker is available
    if ! command -v docker &> /dev/null; then
        print_result "skip" "Docker not available"
        return 0
    fi

    # Get running containers
    local containers
    containers=$(docker ps --format "{{.Names}}" 2>/dev/null) || {
        print_result "skip" "Could not list containers"
        return 0
    }

    if [[ -z "$containers" ]]; then
        print_result "skip" "No running containers"
        return 0
    fi

    # Convert to array
    local container_array
    mapfile -t container_array <<< "$containers"

    if [[ ${#container_array[@]} -lt 2 ]]; then
        print_result "skip" "Need at least 2 containers for DNS test"
        return 0
    fi

    # Pick first container as source
    local source="${container_array[0]}"

    # Check if source has nslookup, dig, or getent
    local dns_cmd=""
    if docker exec "$source" which nslookup &>/dev/null; then
        dns_cmd="nslookup"
    elif docker exec "$source" which dig &>/dev/null; then
        dns_cmd="dig +short"
    elif docker exec "$source" which getent &>/dev/null; then
        dns_cmd="getent hosts"
    fi

    if [[ -z "$dns_cmd" ]]; then
        print_result "skip" "No DNS lookup tool in $source container"
        return 0
    fi

    # Test DNS resolution to other containers
    for target in "${container_array[@]}"; do
        if [[ "$target" != "$source" ]]; then
            local result
            result=$(docker exec "$source" $dns_cmd "$target" 2>/dev/null) || result=""

            if [[ -n "$result" ]]; then
                print_result "pass" "$source -> $target: DNS resolves"
            else
                print_result "fail" "$source -> $target: DNS resolution failed"
            fi
        fi
    done
}

# Test network connectivity between containers
check_container_connectivity() {
    echo ""
    echo "Checking container network connectivity..."
    echo ""

    # Check if docker is available
    if ! command -v docker &> /dev/null; then
        print_result "skip" "Docker not available"
        return 0
    fi

    # Get running containers with their exposed ports
    local containers
    containers=$(docker ps --format "{{.Names}}:{{.Ports}}" 2>/dev/null) || {
        print_result "skip" "Could not list containers"
        return 0
    }

    if [[ -z "$containers" ]]; then
        print_result "skip" "No running containers"
        return 0
    fi

    # Parse container:port mappings
    declare -A container_ports
    while IFS= read -r line; do
        local name ports
        name="${line%%:*}"
        ports="${line#*:}"

        # Extract first internal port (e.g., "0.0.0.0:8080->80/tcp" -> "80")
        if [[ "$ports" =~ -\>([0-9]+) ]]; then
            container_ports["$name"]="${BASH_REMATCH[1]}"
        fi
    done <<< "$containers"

    if [[ ${#container_ports[@]} -lt 2 ]]; then
        print_result "skip" "Need at least 2 containers with exposed ports"
        return 0
    fi

    # Pick first container as source
    local source=""
    for c in "${!container_ports[@]}"; do
        source="$c"
        break
    done

    # Check if source has connectivity tools
    local conn_cmd=""
    if docker exec "$source" which nc &>/dev/null; then
        conn_cmd="nc -z -w 2"
    elif docker exec "$source" which curl &>/dev/null; then
        conn_cmd="curl -s --connect-timeout 2"
    elif docker exec "$source" which wget &>/dev/null; then
        conn_cmd="wget -q --timeout=2 --spider"
    fi

    if [[ -z "$conn_cmd" ]]; then
        print_result "skip" "No connectivity tool in $source container"
        return 0
    fi

    # Test connectivity to other containers
    for target in "${!container_ports[@]}"; do
        if [[ "$target" != "$source" ]]; then
            local port="${container_ports[$target]}"

            if [[ -n "$port" ]]; then
                local result
                if [[ "$conn_cmd" == nc* ]]; then
                    docker exec "$source" $conn_cmd "$target" "$port" &>/dev/null && result="ok" || result=""
                else
                    docker exec "$source" $conn_cmd "http://$target:$port" &>/dev/null && result="ok" || result=""
                fi

                if [[ -n "$result" ]]; then
                    print_result "pass" "$source -> $target:$port: connected"
                else
                    print_result "fail" "$source -> $target:$port: connection failed"
                fi
            fi
        fi
    done
}

# Run custom connectivity tests
run_custom_tests() {
    echo ""
    echo "Running custom connectivity tests..."
    echo ""

    if [[ -z "$CONNECTIVITY_TESTS" ]]; then
        print_result "skip" "No CONNECTIVITY_TESTS configured"
        return 0
    fi

    IFS=',' read -ra tests <<< "$CONNECTIVITY_TESTS"
    for test in "${tests[@]}"; do
        test=$(echo "$test" | xargs)  # Trim whitespace

        # Parse source:target:port
        local source target port
        IFS=':' read -r source target port <<< "$test"

        if [[ -z "$source" ]] || [[ -z "$target" ]] || [[ -z "$port" ]]; then
            print_result "warn" "Invalid test format: $test (expected source:target:port)"
            continue
        fi

        # Check if source container exists
        if ! docker ps --format "{{.Names}}" 2>/dev/null | grep -qx "$source"; then
            print_result "skip" "$source container not running"
            continue
        fi

        # Try connection
        local result=""
        if docker exec "$source" which nc &>/dev/null; then
            docker exec "$source" nc -z -w 2 "$target" "$port" &>/dev/null && result="ok"
        elif docker exec "$source" timeout 2 bash -c "echo >/dev/tcp/$target/$port" &>/dev/null; then
            result="ok"
        fi

        if [[ -n "$result" ]]; then
            print_result "pass" "$source -> $target:$port"
        else
            print_result "fail" "$source -> $target:$port"
        fi
    done
}

# Check external connectivity from containers
check_external_connectivity() {
    echo ""
    echo "Checking external connectivity..."
    echo ""

    # Check if docker is available
    if ! command -v docker &> /dev/null; then
        print_result "skip" "Docker not available"
        return 0
    fi

    # Get first running container
    local container
    container=$(docker ps --format "{{.Names}}" 2>/dev/null | head -1) || {
        print_result "skip" "No running containers"
        return 0
    }

    if [[ -z "$container" ]]; then
        print_result "skip" "No running containers"
        return 0
    fi

    # Check DNS resolution to external host
    if docker exec "$container" which nslookup &>/dev/null; then
        if docker exec "$container" nslookup dns.google &>/dev/null; then
            print_result "pass" "$container: External DNS resolution works"
        else
            print_result "warn" "$container: External DNS resolution failed"
        fi
    elif docker exec "$container" which ping &>/dev/null; then
        if docker exec "$container" ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
            print_result "pass" "$container: External network reachable"
        else
            print_result "warn" "$container: External network unreachable"
        fi
    else
        print_result "skip" "No external connectivity tools available"
    fi
}

# Main execution
main() {
    echo "Service Connectivity Tests"
    echo "=========================="
    echo ""

    check_docker_networks
    check_container_dns
    check_container_connectivity
    run_custom_tests
    check_external_connectivity

    echo ""
    echo "=========================="
    echo "Summary:"
    echo "  Passed: $PASSED"
    echo "  Failed: $FAILURES"
    echo ""

    if [[ $FAILURES -gt 0 ]]; then
        echo -e "${RED}Connectivity Tests: FAILED${NC}"
        exit $EXIT_FAILURE
    elif [[ $PASSED -eq 0 ]]; then
        echo -e "${YELLOW}Connectivity Tests: No tests executed${NC}"
        exit $EXIT_SUCCESS
    else
        echo -e "${GREEN}Connectivity Tests: PASSED${NC}"
        exit $EXIT_SUCCESS
    fi
}

main "$@"
