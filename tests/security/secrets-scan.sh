#!/bin/bash
#
# secrets-scan.sh - Check for exposed secrets in the codebase
#
# Scans for:
# - Hardcoded passwords and API keys
# - Private keys and certificates
# - Environment files that shouldn't be committed
# - Sensitive patterns in configuration files
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

# Track findings
CRITICAL_FINDINGS=0
WARNING_FINDINGS=0

# Script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$SCRIPT_DIR/../.." && pwd)}"

# Files and directories to exclude from scanning
EXCLUDE_PATTERNS=(
    ".git"
    "node_modules"
    "vendor"
    "__pycache__"
    ".pytest_cache"
    "*.log"
    "*.example"
    "*.sample"
    "*.template"
)

# Print finding
print_finding() {
    local severity="$1"
    local message="$2"

    case "$severity" in
        critical)
            echo -e "  ${RED}[CRITICAL]${NC} $message"
            CRITICAL_FINDINGS=$((CRITICAL_FINDINGS + 1))
            ;;
        warning)
            echo -e "  ${YELLOW}[WARNING]${NC} $message"
            WARNING_FINDINGS=$((WARNING_FINDINGS + 1))
            ;;
        info)
            echo -e "  ${GREEN}[INFO]${NC} $message"
            ;;
        ok)
            echo -e "  ${GREEN}[OK]${NC} $message"
            ;;
    esac
}

# Build grep exclude arguments
build_excludes() {
    local excludes=""
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        excludes="$excludes --exclude=$pattern --exclude-dir=$pattern"
    done
    echo "$excludes"
}

# Scan for hardcoded secrets patterns
scan_hardcoded_secrets() {
    echo ""
    echo "Scanning for hardcoded secrets..."
    echo ""

    local exclude_args
    exclude_args=$(build_excludes)

    # Patterns to search for (case insensitive)
    local patterns=(
        "password\s*[:=]\s*['\"][^'\"]{8,}['\"]"
        "api[_-]?key\s*[:=]\s*['\"][^'\"]+['\"]"
        "secret[_-]?key\s*[:=]\s*['\"][^'\"]+['\"]"
        "access[_-]?token\s*[:=]\s*['\"][^'\"]+['\"]"
        "auth[_-]?token\s*[:=]\s*['\"][^'\"]+['\"]"
        "private[_-]?key\s*[:=]\s*['\"][^'\"]+['\"]"
        "aws[_-]?secret"
        "BEGIN\s+(RSA|DSA|EC|OPENSSH)\s+PRIVATE\s+KEY"
        "ghp_[a-zA-Z0-9]{36}"  # GitHub personal access token
        "sk-[a-zA-Z0-9]{48}"   # OpenAI API key pattern
    )

    local found_secrets=0

    for pattern in "${patterns[@]}"; do
        # shellcheck disable=SC2086
        local matches
        matches=$(grep -rniE $exclude_args "$pattern" "$PROJECT_ROOT" 2>/dev/null | head -10) || true

        if [[ -n "$matches" ]]; then
            found_secrets=1
            while IFS= read -r match; do
                # Extract just the filename and line number, not the content
                local file_info
                file_info=$(echo "$match" | cut -d: -f1-2)
                print_finding "critical" "Potential secret in: $file_info"
            done <<< "$matches"
        fi
    done

    if [[ $found_secrets -eq 0 ]]; then
        print_finding "ok" "No hardcoded secrets detected"
    fi
}

# Check for sensitive files
check_sensitive_files() {
    echo ""
    echo "Checking for sensitive files..."
    echo ""

    local sensitive_files=(
        ".env"
        ".env.local"
        ".env.production"
        "*.pem"
        "*.key"
        "*.p12"
        "*.pfx"
        "id_rsa"
        "id_dsa"
        "id_ecdsa"
        "id_ed25519"
        "credentials.json"
        "service-account.json"
        "secrets.yaml"
        "secrets.yml"
        ".htpasswd"
        "*.kdbx"
    )

    local found_sensitive=0

    for pattern in "${sensitive_files[@]}"; do
        local files
        files=$(find "$PROJECT_ROOT" -name "$pattern" -not -path "*/.git/*" -not -path "*/node_modules/*" 2>/dev/null) || true

        if [[ -n "$files" ]]; then
            while IFS= read -r file; do
                # Check if file is in .gitignore
                local relative_path
                relative_path="${file#$PROJECT_ROOT/}"

                if git -C "$PROJECT_ROOT" check-ignore -q "$relative_path" 2>/dev/null; then
                    print_finding "info" "Sensitive file (gitignored): $relative_path"
                else
                    found_sensitive=1
                    print_finding "critical" "Sensitive file NOT gitignored: $relative_path"
                fi
            done <<< "$files"
        fi
    done

    if [[ $found_sensitive -eq 0 ]]; then
        print_finding "ok" "No unprotected sensitive files found"
    fi
}

# Check environment variable exposure
check_env_exposure() {
    echo ""
    echo "Checking environment variable exposure..."
    echo ""

    # Check for .env files that might be committed
    if [[ -f "$PROJECT_ROOT/.env" ]]; then
        # Check if tracked by git
        if git -C "$PROJECT_ROOT" ls-files --error-unmatch .env 2>/dev/null; then
            print_finding "critical" ".env file is tracked by git"
        else
            print_finding "ok" ".env file exists but is not tracked"
        fi
    fi

    # Check docker-compose for hardcoded secrets
    local compose_files
    compose_files=$(find "$PROJECT_ROOT" -name "docker-compose*.yml" -o -name "docker-compose*.yaml" 2>/dev/null) || true

    if [[ -n "$compose_files" ]]; then
        while IFS= read -r compose_file; do
            local hardcoded
            hardcoded=$(grep -E "^\s*(password|secret|key|token)\s*:" "$compose_file" 2>/dev/null | \
                        grep -vE "^\s*#" | \
                        grep -vE '\$\{' | \
                        head -5) || true

            if [[ -n "$hardcoded" ]]; then
                local basename
                basename=$(basename "$compose_file")
                print_finding "warning" "Possible hardcoded secrets in $basename"
            fi
        done <<< "$compose_files"
    fi

    # Verify .env.example exists if .env is used
    if [[ -f "$PROJECT_ROOT/.env" ]] && [[ ! -f "$PROJECT_ROOT/.env.example" ]]; then
        print_finding "warning" "Missing .env.example template"
    else
        print_finding "ok" "Environment configuration appears secure"
    fi
}

# Check Docker secrets configuration
check_docker_secrets() {
    echo ""
    echo "Checking Docker secrets configuration..."
    echo ""

    # Check if docker is available
    if ! command -v docker &> /dev/null; then
        print_finding "info" "Docker not available - skipping container checks"
        return 0
    fi

    # Check running containers for secret exposure
    local containers
    containers=$(docker ps --format "{{.Names}}" 2>/dev/null) || true

    if [[ -z "$containers" ]]; then
        print_finding "info" "No running containers to check"
        return 0
    fi

    while IFS= read -r container; do
        # Check for exposed environment variables with sensitive names
        local sensitive_vars
        sensitive_vars=$(docker inspect "$container" --format '{{range .Config.Env}}{{println .}}{{end}}' 2>/dev/null | \
                        grep -iE "^(PASSWORD|SECRET|KEY|TOKEN|API_KEY)=" | wc -l | tr -d ' ') || true

        if [[ "$sensitive_vars" -gt 0 ]]; then
            print_finding "warning" "$container has $sensitive_vars sensitive env vars"
        fi
    done <<< "$containers"
}

# Main execution
main() {
    echo "Secrets Scan"
    echo "============"
    echo ""
    echo "Scanning: $PROJECT_ROOT"

    scan_hardcoded_secrets
    check_sensitive_files
    check_env_exposure
    check_docker_secrets

    echo ""
    echo "============"
    echo "Summary:"
    echo "  Critical findings: $CRITICAL_FINDINGS"
    echo "  Warnings: $WARNING_FINDINGS"
    echo ""

    if [[ $CRITICAL_FINDINGS -gt 0 ]]; then
        echo -e "${RED}Secrets Scan: FAILED - Critical issues found${NC}"
        exit $EXIT_FAILURE
    elif [[ $WARNING_FINDINGS -gt 0 ]]; then
        echo -e "${YELLOW}Secrets Scan: PASSED with warnings${NC}"
        exit $EXIT_SUCCESS
    else
        echo -e "${GREEN}Secrets Scan: PASSED${NC}"
        exit $EXIT_SUCCESS
    fi
}

main "$@"
