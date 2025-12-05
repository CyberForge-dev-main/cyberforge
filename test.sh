#!/bin/bash

# CyberForge Integration Tests
# Runs health check, rate limiting, and user flow tests

set -e

echo "╔═══════════════════════════════════════════════════╗"
echo "║      CyberForge Integration Tests                ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""

FAILED=0
PASSED=0

# Check Docker
if ! docker ps >/dev/null 2>&1; then
  echo "❌ Docker daemon not running"
  exit 1
fi

# Check containers
RUNNING=$(docker compose ps -q | wc -l)
if [ "$RUNNING" -eq 0 ]; then
  echo "⚠️  No containers running. Start with: docker compose up -d"
  exit 1
fi

# Run tests
echo "Running tests..."
echo ""

if ./tests/health_check.sh; then
  ((PASSED++))
else
  ((FAILED++))
fi

if ./tests/test_rate_limit.sh; then
  ((PASSED++))
else
  ((FAILED++))
fi

if ./tests/user_flow_full.sh; then
  ((PASSED++))
else
  ((FAILED++))
fi

echo ""
echo "═══════════════════════════════════════"
echo "Results: $PASSED passed, $FAILED failed"
echo "═══════════════════════════════════════"

exit $FAILED
