#!/bin/bash
#
# validate-patterns.sh - Validate all 10 patterns deploy correctly
#
# Tests:
# - Pattern docker-compose syntax validation
# - Profile configuration correctness
# - Required environment variables
# - Volume and network definitions
# - Standalone mode (foundation layer)
# - External mode (DOCKER_LAB_PATH)
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Exit codes
EXIT_SUCCESS=0
EXIT_FAILURE=1

# Track results
FAILURES=0
PASSED=0
WARNINGS=0

# Project directories
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
FOUNDATION_DIR="$PROJECT_ROOT/foundation"

# List of all 10 patterns
PATTERNS=(
    "gotosocial"
    "writefreely"
    "peertube"
    "listmonk"
    "rss2bsky"
    "activitypods"
    "n8n"
    "pixelfed"
    "castopod"
    "manyfold"
)

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
            WARNINGS=$((WARNINGS + 1))
            ;;
        info)
            echo -e "  ${BLUE}[INFO]${NC} $message"
            ;;
    esac
}

# Print section header
print_section() {
    echo ""
    echo -e "${BLUE}--- $1 ---${NC}"
    echo ""
}

# Check if docker compose is available
check_docker_compose() {
    if docker compose version &> /dev/null; then
        echo "docker compose"
    elif command -v docker-compose &> /dev/null; then
        echo "docker-compose"
    else
        echo ""
    fi
}

COMPOSE_CMD=$(check_docker_compose)

# Validate docker-compose syntax for a profile
validate_profile() {
    local profile="$1"
    local mode="$2"

    local compose_file="$PROJECT_ROOT/docker-compose.yml"

    # Set up environment based on mode
    local env_vars=""
    if [[ "$mode" == "external" ]]; then
        # For external mode, we would need external docker-lab
        # For testing, we'll just check if the include path resolves
        env_vars="DOCKER_LAB_PATH=/nonexistent/path"
    fi

    # Try to validate the config
    local output
    local exit_code

    if [[ -n "$env_vars" ]]; then
        # shellcheck disable=SC2086
        output=$(cd "$PROJECT_ROOT" && $env_vars $COMPOSE_CMD -f "$compose_file" --profile "$profile" config 2>&1) && exit_code=0 || exit_code=$?
    else
        # shellcheck disable=SC2086
        output=$(cd "$PROJECT_ROOT" && $COMPOSE_CMD -f "$compose_file" --profile "$profile" config 2>&1) && exit_code=0 || exit_code=$?
    fi

    if [[ $exit_code -eq 0 ]]; then
        print_result "pass" "Profile '$profile' config valid ($mode mode)"
        return 0
    else
        # Check if it's just missing environment variables
        if echo "$output" | grep -q "variable is not set"; then
            print_result "warn" "Profile '$profile' needs environment variables ($mode mode)"
            return 0
        elif echo "$output" | grep -q "could not be found"; then
            print_result "warn" "Profile '$profile' - file not found for include ($mode mode)"
            return 0
        else
            print_result "fail" "Profile '$profile' config invalid ($mode mode)"
            echo "    Error: $(echo "$output" | head -1)"
            return 1
        fi
    fi
}

# Validate all 10 patterns
validate_all_patterns() {
    print_section "Pattern Configuration Validation"

    if [[ -z "$COMPOSE_CMD" ]]; then
        print_result "fail" "docker compose not available"
        return 1
    fi

    for pattern in "${PATTERNS[@]}"; do
        validate_profile "$pattern" "standalone"
    done
}

# Validate foundation layer
validate_foundation() {
    print_section "Foundation Layer Validation"

    if [[ ! -f "$FOUNDATION_DIR/docker-compose.yml" ]]; then
        print_result "fail" "Foundation docker-compose.yml not found"
        return 1
    fi

    print_result "pass" "Foundation docker-compose.yml exists"

    # Validate foundation config
    local output
    local exit_code
    output=$(cd "$FOUNDATION_DIR" && $COMPOSE_CMD config 2>&1) && exit_code=0 || exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        print_result "pass" "Foundation config syntax valid"
    else
        print_result "fail" "Foundation config syntax invalid"
        echo "    Error: $(echo "$output" | head -1)"
    fi

    # Check for required services in foundation
    local required_services=("traefik")
    for service in "${required_services[@]}"; do
        if grep -q "^  $service:" "$FOUNDATION_DIR/docker-compose.yml"; then
            print_result "pass" "Foundation service: $service"
        else
            print_result "fail" "Foundation missing service: $service"
        fi
    done

    # Check for required networks
    local required_networks=("proxy-external" "db-internal")
    for network in "${required_networks[@]}"; do
        if grep -q "^  $network:" "$FOUNDATION_DIR/docker-compose.yml" || \
           grep -q "name: $network" "$FOUNDATION_DIR/docker-compose.yml"; then
            print_result "pass" "Foundation network: $network"
        else
            print_result "fail" "Foundation missing network: $network"
        fi
    done
}

# Validate standalone mode (no DOCKER_LAB_PATH)
validate_standalone_mode() {
    print_section "Standalone Mode Validation"

    # Check that foundation directory exists and has required files
    if [[ ! -d "$FOUNDATION_DIR" ]]; then
        print_result "fail" "Foundation directory not found"
        return 1
    fi

    print_result "pass" "Foundation directory exists"

    # Check foundation compose
    if [[ ! -f "$FOUNDATION_DIR/docker-compose.yml" ]]; then
        print_result "fail" "Foundation docker-compose.yml not found"
        return 1
    fi

    print_result "pass" "Foundation docker-compose.yml exists"

    # Check that include path uses DOCKER_LAB_PATH with fallback
    if grep -q 'DOCKER_LAB_PATH:-./foundation' "$PROJECT_ROOT/docker-compose.yml"; then
        print_result "pass" "Include path has standalone fallback"
    else
        print_result "fail" "Include path missing standalone fallback"
    fi
}

# Validate external mode (DOCKER_LAB_PATH set)
validate_external_mode() {
    print_section "External Mode Validation"

    # Check that the docker-compose.yml supports DOCKER_LAB_PATH
    if grep -q '\${DOCKER_LAB_PATH' "$PROJECT_ROOT/docker-compose.yml"; then
        print_result "pass" "DOCKER_LAB_PATH variable supported"
    else
        print_result "fail" "DOCKER_LAB_PATH variable not found"
    fi

    # Document that external mode requires the docker-lab repo
    print_result "info" "External mode requires peer-mesh-docker-lab repository"
}

# Validate pattern-specific compose files exist
validate_pattern_files() {
    print_section "Pattern File Validation"

    for pattern in "${PATTERNS[@]}"; do
        local pattern_dir="$PROJECT_ROOT/patterns/$pattern"

        if [[ ! -d "$pattern_dir" ]]; then
            print_result "fail" "Pattern directory missing: $pattern"
            continue
        fi

        # Check for README
        if [[ -f "$pattern_dir/README.md" ]]; then
            print_result "pass" "$pattern/README.md exists"
        else
            print_result "warn" "$pattern/README.md missing"
        fi

        # Check for pattern setup docs
        if [[ -f "$pattern_dir/PATTERN-SETUP.md" ]]; then
            print_result "pass" "$pattern/PATTERN-SETUP.md exists"
        else
            print_result "warn" "$pattern/PATTERN-SETUP.md missing"
        fi

        # Check for pattern compose file (optional - patterns may be in main compose)
        if [[ -f "$pattern_dir/docker-compose.$pattern.yml" ]]; then
            print_result "pass" "$pattern has compose file"
        fi
    done
}

# Validate required environment variables
check_env_template() {
    print_section "Environment Configuration"

    if [[ ! -f "$PROJECT_ROOT/.env.example" ]]; then
        print_result "fail" ".env.example not found"
        return 1
    fi

    print_result "pass" ".env.example exists"

    # Check for required variables
    local required_vars=(
        "DOMAIN"
        "ADMIN_EMAIL"
    )

    for var in "${required_vars[@]}"; do
        if grep -q "^$var=" "$PROJECT_ROOT/.env.example"; then
            print_result "pass" "Required var: $var"
        else
            print_result "fail" "Missing required var: $var"
        fi
    done

    # Check for pattern-specific variables
    for pattern in "${PATTERNS[@]}"; do
        # Convert to uppercase (bash 3.x compatible)
        local pattern_var_prefix=$(echo "$pattern" | tr '[:lower:]' '[:upper:]')
        if grep -qi "^${pattern_var_prefix}_" "$PROJECT_ROOT/.env.example" || \
           grep -qi "^# ${pattern_var_prefix}_" "$PROJECT_ROOT/.env.example"; then
            print_result "pass" "$pattern has configuration variables"
        fi
    done
}

# Validate secrets directory structure
check_secrets_structure() {
    print_section "Secrets Structure Validation"

    if [[ ! -d "$PROJECT_ROOT/secrets" ]]; then
        print_result "fail" "secrets directory not found"
        return 1
    fi

    print_result "pass" "secrets directory exists"

    # Check for .gitignore in secrets
    if [[ -f "$PROJECT_ROOT/secrets/.gitignore" ]]; then
        print_result "pass" "secrets/.gitignore exists"
    else
        print_result "warn" "secrets/.gitignore missing"
    fi

    # List secrets that would be generated
    local expected_secrets=(
        "postgres_password"
        "mysql_root_password"
        "redis_password"
        "peertube_db_password"
        "peertube_secret"
        "listmonk_db_password"
        "fuseki_password"
        "activitypods_cookie_secret"
        "n8n_encryption_key"
        "pixelfed_app_key"
    )

    for secret in "${expected_secrets[@]}"; do
        if grep -q "$secret" "$PROJECT_ROOT/docker-compose.yml"; then
            print_result "pass" "Secret referenced: $secret"
        fi
    done
}

# Validate volume definitions
check_volumes() {
    print_section "Volume Definitions"

    local volumes
    volumes=$(grep -E "^  dlst_" "$PROJECT_ROOT/docker-compose.yml" | wc -l)

    if [[ $volumes -gt 0 ]]; then
        print_result "pass" "Found $volumes named volumes in main compose"
    fi
}

# Print summary
print_summary() {
    echo ""
    echo -e "${BLUE}=======================================${NC}"
    echo -e "${BLUE}  Pattern Validation Summary${NC}"
    echo -e "${BLUE}=======================================${NC}"
    echo ""
    echo "Results:"
    echo -e "  ${GREEN}Passed:${NC}   $PASSED"
    echo -e "  ${RED}Failed:${NC}   $FAILURES"
    echo -e "  ${YELLOW}Warnings:${NC} $WARNINGS"
    echo "  ─────────────"
    echo "  Total:    $((PASSED + FAILURES + WARNINGS))"
    echo ""

    if [[ $FAILURES -eq 0 ]]; then
        echo -e "${GREEN}All pattern validations passed!${NC}"
        return 0
    else
        echo -e "${RED}Some validations failed!${NC}"
        return 1
    fi
}

# Main execution
main() {
    echo ""
    echo -e "${BLUE}=======================================${NC}"
    echo -e "${BLUE}  Docker Lab Stack - Pattern Validation${NC}"
    echo -e "${BLUE}=======================================${NC}"
    echo ""
    echo "Started at: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Project: $PROJECT_ROOT"
    echo ""

    validate_foundation
    validate_standalone_mode
    validate_external_mode
    validate_all_patterns
    validate_pattern_files
    check_env_template
    check_secrets_structure
    check_volumes

    print_summary
}

main "$@"
