#!/usr/bin/env bash
set -euo pipefail

TS="$(date +%Y%m%d_%H%M%S)"
OUTDIR="dumps/diagnostics/${TS}"
mkdir -p "$OUTDIR"

{
  echo "CYBERFORGE DIAGNOSTICS"
  echo "timestamp=${TS}"
  echo "pwd=$(pwd)"
  echo
  echo "== git =="
  git rev-parse --abbrev-ref HEAD || true
  git rev-parse HEAD || true
  git status --porcelain || true
  echo
  echo "== compose config (normalized) =="
  docker compose config || true
  echo
  echo "== compose ps =="
  docker compose ps || true
  echo
  echo "== api health =="
  curl -sS http://localhost:5000/api/health || true
  echo
} > "${OUTDIR}/DIAGNOSTIC_REPORT.txt"

# Lightweight dev snapshot (human/LLM friendly)
{
  echo "# CyberForge Dev Snapshot"
  echo
  echo "- Generated at: ${TS}"
  echo "- Branch: $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
  echo "- Commit: $(git rev-parse HEAD 2>/dev/null || echo unknown)"
  echo
  echo "## Quick links (dev defaults)"
  echo "- Website: http://localhost:3000"
  echo "- Backend: http://localhost:5000"
  echo "- Juice Shop: http://localhost:3001"
  echo "- SSH: 2222-2224"
  echo
  echo "## Notes"
  echo "- This is a snapshot, not a contract."
} > "${OUTDIR}/DEV_SNAPSHOT.md"

# Bundle for pasting into a new LLM chat
{
  echo "# CYBERFORGE LLM BUNDLE"
  echo
  echo "## CONTRACT (canonical)"
  cat docs/CONTRACT.md
  echo
  echo "## DEV SNAPSHOT (generated)"
  cat "${OUTDIR}/DEV_SNAPSHOT.md"
  echo
  echo "## DIAGNOSTIC (generated, tail)"
  tail -n 200 "${OUTDIR}/DIAGNOSTIC_REPORT.txt"
} > "${OUTDIR}/LLM_BUNDLE.md"

echo "$OUTDIR"
