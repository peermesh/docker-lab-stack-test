#!/bin/bash
#
# permissions-check.sh - Verify container and file permissions
#
# Checks:
# - Containers not running as root
# - Proper file permissions on sensitive files
# - No privileged containers unless required
# - Capability restrictions
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

# Track failures
FAILURES=0
WARNINGS=0

# Script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$SCRIPT_DIR/../.." && pwd)}"

# Print result
print_result() {
    local status="$1"
    local message="$2"

    case "$status" in
        pass)
            echo -e "  ${GREEN}[PASS]${NC} $message"
            ;;
        fail)
            echo -e "  ${RED}[FAIL]${NC} $message"
            FAILURES=$((FAILURES + 1))
            ;;
        warn)
            echo -e "  ${YELLOW}[WARN]${NC} $message"
            WARNINGS=$((WARNINGS + 1))
            ;;
        skip)
            echo -e "  ${YELLOW}[SKIP]${NC} $message"
            ;;
    esac
}

# Check file permissions
check_file_permissions() {
    echo ""
    echo "Checking file permissions..."
    echo ""

    # Check that sensitive files are not world-readable
    local sensitive_patterns=(
        "*.key"
        "*.pem"
        ".env"
        ".env.*"
        "*password*"
        "*secret*"
        "*.p12"
        "*.pfx"
    )

    local found_issues=0

    for pattern in "${sensitive_patterns[@]}"; do
        local files
        files=$(find "$PROJECT_ROOT" -name "$pattern" -not -path "*/.git/*" -not -path "*/node_modules/*" 2>/dev/null) || true

        if [[ -n "$files" ]]; then
            while IFS= read -r file; do
                local perms
                perms=$(stat -f "%Lp" "$file" 2>/dev/null || stat -c "%a" "$file" 2>/dev/null) || continue

                local relative_path
                relative_path="${file#$PROJECT_ROOT/}"

                # Check if world-readable (last digit > 0 means others have some access)
                local others_perm
                others_perm=$((perms % 10))

                if [[ $others_perm -gt 0 ]]; then
                    found_issues=1
                    print_result "warn" "$relative_path is world-readable ($perms)"
                fi
            done <<< "$files"
        fi
    done

    if [[ $found_issues -eq 0 ]]; then
        print_result "pass" "Sensitive files have appropriate permissions"
    fi

    # Check script permissions
    local scripts
    scripts=$(find "$PROJECT_ROOT" -name "*.sh" -not -path "*/.git/*" 2>/dev/null) || true

    if [[ -n "$scripts" ]]; then
        local non_exec=0
        while IFS= read -r script; do
            if [[ ! -x "$script" ]]; then
                non_exec=$((non_exec + 1))
            fi
        done <<< "$scripts"

        if [[ $non_exec -gt 0 ]]; then
            print_result "warn" "$non_exec shell scripts are not executable"
        else
            print_result "pass" "All shell scripts are executable"
        fi
    fi
}

# Check container security settings
check_container_permissions() {
    echo ""
    echo "Checking container permissions..."
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

    while IFS= read -r container; do
        # Check if running as root
        local user
        user=$(docker inspect "$container" --format '{{.Config.User}}' 2>/dev/null) || continue

        if [[ -z "$user" ]] || [[ "$user" == "root" ]] || [[ "$user" == "0" ]]; then
            print_result "warn" "$container runs as root user"
        else
            print_result "pass" "$container runs as non-root user ($user)"
        fi

        # Check if privileged
        local privileged
        privileged=$(docker inspect "$container" --format '{{.HostConfig.Privileged}}' 2>/dev/null) || continue

        if [[ "$privileged" == "true" ]]; then
            print_result "fail" "$container runs in privileged mode"
        else
            print_result "pass" "$container is not privileged"
        fi

        # Check capabilities
        local cap_add
        cap_add=$(docker inspect "$container" --format '{{.HostConfig.CapAdd}}' 2>/dev/null) || continue

        if [[ "$cap_add" != "[]" ]] && [[ -n "$cap_add" ]]; then
            print_result "warn" "$container has added capabilities: $cap_add"
        fi

        # Check for host network mode
        local network_mode
        network_mode=$(docker inspect "$container" --format '{{.HostConfig.NetworkMode}}' 2>/dev/null) || continue

        if [[ "$network_mode" == "host" ]]; then
            print_result "warn" "$container uses host network mode"
        fi

        # Check for mounted docker socket
        local mounts
        mounts=$(docker inspect "$container" --format '{{range .Mounts}}{{.Source}}{{"\n"}}{{end}}' 2>/dev/null) || continue

        if echo "$mounts" | grep -q "/var/run/docker.sock"; then
            print_result "warn" "$container has docker socket mounted"
        fi

    done <<< "$containers"
}

# Check docker-compose security settings
check_compose_security() {
    echo ""
    echo "Checking docker-compose security configuration..."
    echo ""

    local compose_files
    compose_files=$(find "$PROJECT_ROOT" -name "docker-compose*.yml" -o -name "docker-compose*.yaml" 2>/dev/null) || true

    if [[ -z "$compose_files" ]]; then
        print_result "skip" "No docker-compose files found"
        return 0
    fi

    while IFS= read -r compose_file; do
        local basename
        basename=$(basename "$compose_file")

        # Check for privileged: true
        if grep -q "privileged:\s*true" "$compose_file" 2>/dev/null; then
            print_result "warn" "$basename contains privileged containers"
        fi

        # Check for security_opt settings
        if grep -q "security_opt:" "$compose_file" 2>/dev/null; then
            print_result "pass" "$basename has security_opt configuration"
        fi

        # Check for read_only root filesystem
        if grep -q "read_only:\s*true" "$compose_file" 2>/dev/null; then
            print_result "pass" "$basename uses read-only containers"
        fi

        # Check for cap_drop
        if grep -q "cap_drop:" "$compose_file" 2>/dev/null; then
            print_result "pass" "$basename drops capabilities"
        else
            print_result "warn" "$basename doesn't explicitly drop capabilities"
        fi

    done <<< "$compose_files"
}

# Check Dockerfile security practices
check_dockerfile_security() {
    echo ""
    echo "Checking Dockerfile security practices..."
    echo ""

    local dockerfiles
    dockerfiles=$(find "$PROJECT_ROOT" -name "Dockerfile*" -not -path "*/.git/*" 2>/dev/null) || true

    if [[ -z "$dockerfiles" ]]; then
        print_result "skip" "No Dockerfiles found"
        return 0
    fi

    while IFS= read -r dockerfile; do
        local basename
        basename=$(basename "$dockerfile")
        local dirname
        dirname=$(dirname "$dockerfile")
        local relative_dir
        relative_dir="${dirname#$PROJECT_ROOT/}"

        # Check for USER instruction
        if grep -qE "^\s*USER\s+" "$dockerfile" 2>/dev/null; then
            print_result "pass" "$relative_dir/$basename sets USER"
        else
            print_result "warn" "$relative_dir/$basename doesn't set USER (runs as root)"
        fi

        # Check for HEALTHCHECK
        if grep -qE "^\s*HEALTHCHECK\s+" "$dockerfile" 2>/dev/null; then
            print_result "pass" "$relative_dir/$basename has HEALTHCHECK"
        fi

        # Check for latest tag usage
        if grep -qE "FROM\s+\S+:latest" "$dockerfile" 2>/dev/null; then
            print_result "warn" "$relative_dir/$basename uses :latest tag"
        fi

    done <<< "$dockerfiles"
}

# Main execution
main() {
    echo "Permissions Check"
    echo "================="
    echo ""
    echo "Project root: $PROJECT_ROOT"

    check_file_permissions
    check_container_permissions
    check_compose_security
    check_dockerfile_security

    echo ""
    echo "================="
    echo "Summary:"
    echo "  Failures: $FAILURES"
    echo "  Warnings: $WARNINGS"
    echo ""

    if [[ $FAILURES -gt 0 ]]; then
        echo -e "${RED}Permissions Check: FAILED${NC}"
        exit $EXIT_FAILURE
    elif [[ $WARNINGS -gt 0 ]]; then
        echo -e "${YELLOW}Permissions Check: PASSED with warnings${NC}"
        exit $EXIT_SUCCESS
    else
        echo -e "${GREEN}Permissions Check: PASSED${NC}"
        exit $EXIT_SUCCESS
    fi
}

main "$@"
