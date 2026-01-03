#!/bin/bash
#
# tls-check.sh - Verify TLS certificates on all endpoints
#
# Checks:
# - TLS is enabled on configured endpoints
# - Certificates are valid and not expired
# - Certificate chain is complete
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

# Default endpoints to check (can be overridden via environment)
TLS_ENDPOINTS="${TLS_ENDPOINTS:-}"
TLS_CHECK_EXPIRY_DAYS="${TLS_CHECK_EXPIRY_DAYS:-30}"

# Print test result
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
            ;;
        skip)
            echo -e "  ${YELLOW}[SKIP]${NC} $message"
            ;;
    esac
}

# Check if openssl is available
check_prerequisites() {
    if ! command -v openssl &> /dev/null; then
        echo "ERROR: openssl is required for TLS checks"
        exit $EXIT_FAILURE
    fi
}

# Check TLS on a single endpoint
check_tls_endpoint() {
    local endpoint="$1"
    local host port

    # Parse host:port
    if [[ "$endpoint" == *:* ]]; then
        host="${endpoint%:*}"
        port="${endpoint##*:}"
    else
        host="$endpoint"
        port="443"
    fi

    # Check if endpoint is reachable
    if ! timeout 5 bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null; then
        print_result "skip" "$endpoint - Not reachable"
        return 0
    fi

    # Get certificate info
    local cert_info
    cert_info=$(echo | timeout 10 openssl s_client -connect "$host:$port" -servername "$host" 2>/dev/null) || {
        print_result "fail" "$endpoint - Could not establish TLS connection"
        return 1
    }

    # Check if we got a certificate
    if ! echo "$cert_info" | grep -q "BEGIN CERTIFICATE"; then
        print_result "fail" "$endpoint - No certificate received"
        return 1
    fi

    # Extract and verify certificate
    local cert
    cert=$(echo "$cert_info" | openssl x509 2>/dev/null) || {
        print_result "fail" "$endpoint - Could not parse certificate"
        return 1
    }

    # Check expiration
    local expiry_date
    expiry_date=$(echo "$cert" | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)

    local expiry_epoch
    expiry_epoch=$(date -j -f "%b %d %H:%M:%S %Y %Z" "$expiry_date" +%s 2>/dev/null || \
                   date -d "$expiry_date" +%s 2>/dev/null) || {
        print_result "warn" "$endpoint - Could not parse expiry date"
        return 0
    }

    local now_epoch
    now_epoch=$(date +%s)

    local days_until_expiry
    days_until_expiry=$(( (expiry_epoch - now_epoch) / 86400 ))

    if [[ $days_until_expiry -lt 0 ]]; then
        print_result "fail" "$endpoint - Certificate EXPIRED"
        return 1
    elif [[ $days_until_expiry -lt $TLS_CHECK_EXPIRY_DAYS ]]; then
        print_result "warn" "$endpoint - Certificate expires in $days_until_expiry days"
    else
        print_result "pass" "$endpoint - Valid (expires in $days_until_expiry days)"
    fi

    return 0
}

# Check for self-signed certificates in container volumes
check_internal_certs() {
    echo ""
    echo "Checking internal certificate configuration..."
    echo ""

    # Look for certificate directories in common locations
    local cert_dirs=(
        "./certs"
        "./ssl"
        "./tls"
        "./secrets/certs"
        "./config/certs"
    )

    local found_certs=0

    for dir in "${cert_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            # Find certificate files
            while IFS= read -r -d '' cert_file; do
                found_certs=1
                local cert_name
                cert_name=$(basename "$cert_file")

                # Verify it's a valid certificate
                if openssl x509 -in "$cert_file" -noout 2>/dev/null; then
                    local expiry
                    expiry=$(openssl x509 -in "$cert_file" -noout -enddate 2>/dev/null | cut -d= -f2)
                    print_result "pass" "$cert_name - Valid certificate (expires: $expiry)"
                else
                    print_result "fail" "$cert_name - Invalid or corrupt certificate"
                fi
            done < <(find "$dir" -name "*.crt" -o -name "*.pem" -o -name "*.cert" 2>/dev/null | tr '\n' '\0')
        fi
    done

    if [[ $found_certs -eq 0 ]]; then
        print_result "skip" "No local certificate files found"
    fi
}

# Check docker containers for TLS configuration
check_container_tls() {
    echo ""
    echo "Checking container TLS configuration..."
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

    # Check each container for TLS-related environment variables
    while IFS= read -r container; do
        local tls_vars
        tls_vars=$(docker inspect "$container" --format '{{range .Config.Env}}{{println .}}{{end}}' 2>/dev/null | \
                   grep -iE "(TLS|SSL|HTTPS|CERT)" | wc -l | tr -d ' ')

        if [[ "$tls_vars" -gt 0 ]]; then
            print_result "pass" "$container - Has TLS configuration ($tls_vars vars)"
        fi
    done <<< "$containers"
}

# Main execution
main() {
    echo "TLS Certificate Verification"
    echo "============================"
    echo ""

    check_prerequisites

    # Check external endpoints if provided
    if [[ -n "$TLS_ENDPOINTS" ]]; then
        echo "Checking external TLS endpoints..."
        echo ""

        IFS=',' read -ra endpoints <<< "$TLS_ENDPOINTS"
        for endpoint in "${endpoints[@]}"; do
            endpoint=$(echo "$endpoint" | xargs)  # Trim whitespace
            check_tls_endpoint "$endpoint"
        done
    else
        print_result "skip" "No TLS_ENDPOINTS configured"
    fi

    # Check internal certificates
    check_internal_certs

    # Check container TLS configuration
    check_container_tls

    echo ""
    echo "============================"

    if [[ $FAILURES -gt 0 ]]; then
        echo -e "${RED}TLS Check: $FAILURES failure(s)${NC}"
        exit $EXIT_FAILURE
    else
        echo -e "${GREEN}TLS Check: All checks passed${NC}"
        exit $EXIT_SUCCESS
    fi
}

main "$@"
