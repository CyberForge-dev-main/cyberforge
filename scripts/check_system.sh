#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:5000}"
TS="$(date +%s)"
USER="${CF_USER:-check_${TS}}"
PASS="${CF_PASS:-Pass123}"
EMAIL="${USER}@test.local"

echo "╔═══════════════════════════════════════════════════╗"
echo "║      CyberForge v4 System Check                   ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""

echo "═══ Docker Containers ═══"
docker compose ps
echo ""

echo "═══ Backend Health ═══"
curl -sS "$BASE_URL/api/health" | jq .
echo ""

echo "═══ Git Status ═══"
git log --oneline -3
echo ""

echo "═══ API Smoke Test ═══"

# 1) Register (idempotent-ish for diagnostics)
curl -sS -X POST "$BASE_URL/api/register" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$USER\",\"email\":\"$EMAIL\",\"password\":\"$PASS\"}" >/dev/null || true

# 2) Login (STRICT): token must exist, otherwise script fails here
TOKEN="$(
  curl -sS -X POST "$BASE_URL/api/login" \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"$USER\",\"password\":\"$PASS\"}" \
  | jq -re '.access_token // empty'
)"
echo "Login Token: ${TOKEN:0:20}..."
echo ""

CHALLENGES="$(curl -sS "$BASE_URL/api/challenges" | jq 'length')"
echo "Challenges Count: $CHALLENGES"

RESP="$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/api/submit_flag" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"challenge_id":1,"flag":"flag{welcome_to_ssh}"}')"

CODE="$(echo "$RESP" | tail -n1)"
BODY="$(echo "$RESP" | head -n-1)"

echo "Submit HTTP: $CODE"
echo "$BODY" | jq -r '.correct // empty' >/dev/null && echo "Submit Flag Success: $(echo "$BODY" | jq -r '.correct')" || echo "Submit Flag Success: <non-json>"

LEADERBOARD="$(curl -sS "$BASE_URL/api/leaderboard" -H "Authorization: Bearer $TOKEN" | jq 'length')"
echo "Leaderboard Users: $LEADERBOARD"
echo ""

echo "═══ SSH ch1 Flag ═══"
sshpass -p 'password123' ssh -p 2222 -o StrictHostKeyChecking=no ctfuser@localhost "cat ~/challenge/flag.txt"
echo ""

echo "╔═══════════════════════════════════════════════════╗"
echo "║      Check Complete                               ║"
echo "╚═══════════════════════════════════════════════════╝"
