#!/usr/bin/env bash
set -euo pipefail

TS="$(date +%Y%m%d_%H%M%S)"
REV="$(git rev-parse --short HEAD 2>/dev/null || echo nogit)"
OUT="dumps/dump_${TS}_${REV}.txt"
mkdir -p dumps

redact() { sed -E 's/((PASS|PASSWORD|SECRET|TOKEN|JWT|KEY)=)[^[:space:]]+/\1<redacted>/gI'; }

{
  echo "=== CyberForge system dump ==="
  echo "ts: ${TS}"
  echo "rev: ${REV}"
  echo

  echo "## git"
  git status --porcelain=v1 2>/dev/null || true
  git log --oneline -10 2>/dev/null || true
  echo

  echo "## docker compose ps"
  docker compose ps 2>/dev/null || docker-compose ps 2>/dev/null || true
  echo

  echo "## containers (names/images/status)"
  docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}' 2>/dev/null || true
  echo

  echo "## health endpoints"
  (curl -sS http://localhost:5000/api/health || true) | head -c 2000; echo
  (curl -sS http://localhost:5000/api/challenges || true) | head -c 2000; echo
  echo

  echo "## env (redacted, best-effort)"
  (env | sort | redact) || true
  echo

  echo "## file checksums (key scripts)"
  for f in Makefile scripts/test_rate_limit.sh scripts/check_system.sh scripts/user_flow_full.sh; do
    if [ -f "$f" ]; then
      sha256sum "$f"
    fi
  done
  echo
} > "$OUT"

echo "Wrote: $OUT"
ls -lh "$OUT"
