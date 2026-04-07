#!/bin/bash
#
# run-all.sh - Master test runner for core-stack-test
#
# Runs all test suites and produces a summary report
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Results array
declare -a TEST_RESULTS=()

# Print header
print_header() {
    echo ""
    echo -e "${BLUE}=======================================${NC}"
    echo -e "${BLUE}  Core Stack Test Suite${NC}"
    echo -e "${BLUE}=======================================${NC}"
    echo ""
    echo "Started at: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
}

# Print section header
print_section() {
    echo ""
    echo -e "${YELLOW}--- $1 ---${NC}"
    echo ""
}

# Run a test script and track results
run_test() {
    local test_name="$1"
    local test_script="$2"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    if [[ ! -f "$test_script" ]]; then
        echo -e "  ${YELLOW}[SKIP]${NC} $test_name - Script not found"
        SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
        TEST_RESULTS+=("SKIP: $test_name")
        return 0
    fi

    if [[ ! -x "$test_script" ]]; then
        echo -e "  ${YELLOW}[SKIP]${NC} $test_name - Script not executable"
        SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
        TEST_RESULTS+=("SKIP: $test_name")
        return 0
    fi

    echo -n "  Running: $test_name... "

    # Run test and capture output
    local output
    local exit_code
    output=$("$test_script" 2>&1) && exit_code=0 || exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        echo -e "${GREEN}[PASS]${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        TEST_RESULTS+=("PASS: $test_name")
    else
        echo -e "${RED}[FAIL]${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        TEST_RESULTS+=("FAIL: $test_name")

        # Show failure details
        if [[ -n "$output" ]]; then
            echo "    Output:"
            echo "$output" | sed 's/^/      /'
        fi
    fi
}

# Print summary
print_summary() {
    echo ""
    echo -e "${BLUE}=======================================${NC}"
    echo -e "${BLUE}  Test Summary${NC}"
    echo -e "${BLUE}=======================================${NC}"
    echo ""
    echo "Completed at: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo "Results:"
    echo -e "  ${GREEN}Passed:${NC}  $PASSED_TESTS"
    echo -e "  ${RED}Failed:${NC}  $FAILED_TESTS"
    echo -e "  ${YELLOW}Skipped:${NC} $SKIPPED_TESTS"
    echo "  ─────────────"
    echo "  Total:   $TOTAL_TESTS"
    echo ""

    if [[ $FAILED_TESTS -gt 0 ]]; then
        echo -e "${RED}FAILED TESTS:${NC}"
        for result in "${TEST_RESULTS[@]}"; do
            if [[ "$result" == FAIL:* ]]; then
                echo "  - ${result#FAIL: }"
            fi
        done
        echo ""
    fi

    if [[ $FAILED_TESTS -eq 0 && $PASSED_TESTS -gt 0 ]]; then
        echo -e "${GREEN}All tests passed!${NC}"
        return 0
    elif [[ $FAILED_TESTS -gt 0 ]]; then
        echo -e "${RED}Some tests failed!${NC}"
        return 1
    else
        echo -e "${YELLOW}No tests were run${NC}"
        return 0
    fi
}

# Check prerequisites
check_prerequisites() {
    print_section "Prerequisites Check"

    local missing=0

    # Check for docker
    if command -v docker &> /dev/null; then
        echo -e "  ${GREEN}[OK]${NC} docker is available"
    else
        echo -e "  ${RED}[MISSING]${NC} docker is not installed"
        missing=1
    fi

    # Check for docker compose
    if docker compose version &> /dev/null; then
        echo -e "  ${GREEN}[OK]${NC} docker compose is available"
    elif command -v docker-compose &> /dev/null; then
        echo -e "  ${GREEN}[OK]${NC} docker-compose is available"
    else
        echo -e "  ${RED}[MISSING]${NC} docker compose is not installed"
        missing=1
    fi

    # Check for curl
    if command -v curl &> /dev/null; then
        echo -e "  ${GREEN}[OK]${NC} curl is available"
    else
        echo -e "  ${YELLOW}[WARN]${NC} curl is not installed (some tests may fail)"
    fi

    # Check for openssl
    if command -v openssl &> /dev/null; then
        echo -e "  ${GREEN}[OK]${NC} openssl is available"
    else
        echo -e "  ${YELLOW}[WARN]${NC} openssl is not installed (TLS tests may fail)"
    fi

    return $missing
}

# Main execution
main() {
    print_header

    # Check prerequisites
    if ! check_prerequisites; then
        echo ""
        echo -e "${RED}ERROR: Missing required prerequisites${NC}"
        exit 1
    fi

    # Security Tests
    print_section "Security Tests"
    run_test "TLS Certificate Check" "$SCRIPT_DIR/security/tls-check.sh"
    run_test "Secrets Scan" "$SCRIPT_DIR/security/secrets-scan.sh"
    run_test "Permissions Check" "$SCRIPT_DIR/security/permissions-check.sh"

    # Pattern Validation Tests
    print_section "Pattern Validation Tests"
    run_test "Pattern Configuration" "$SCRIPT_DIR/integration/validate-patterns.sh"

    # Integration Tests
    print_section "Integration Tests"
    run_test "Health Checks" "$SCRIPT_DIR/integration/health-checks.sh"
    run_test "Service Connectivity" "$SCRIPT_DIR/integration/connectivity.sh"
    run_test "Database Connections" "$SCRIPT_DIR/integration/database.sh"

    # Print final summary
    print_summary
}

# Run main
main "$@"
