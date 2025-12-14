#!/bin/bash
set -euo pipefail

BASE_URL="http://localhost:5000"
USER="uflow_$(date +%s)"
PASS="Pass123"
EMAIL="${USER}@test.local"

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required (sudo apt install jq)"; exit 1
fi

echo "== User Flow E2E =="

echo "1) Register $USER"
REG=$(curl -s -X POST "$BASE_URL/api/register" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$USER\",\"email\":\"$EMAIL\",\"password\":\"$PASS\"}")
echo "$REG" | jq .
if [ "$(echo "$REG" | jq -r '.message')" != "User registered successfully" ]; then
  echo "Registration failed"; exit 1
fi

echo
echo "2) Login"
TOKEN=$(curl -s -X POST "$BASE_URL/api/login" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$USER\",\"password\":\"$PASS\"}" | jq -r '.access_token')
if [ "$TOKEN" = "null" ] || [ -z "$TOKEN" ]; then
  echo "Login failed"; exit 1
fi
echo "Token: ${TOKEN:0:20}..."

echo
echo "3) Get challenges"
CHALS=$(curl -s "$BASE_URL/api/challenges")
echo "$CHALS" | jq .
CID=$(echo "$CHALS" | jq -r '.[0].id')
if [ "$CID" = "null" ] || [ -z "$CID" ]; then
  echo "No challenges found"; exit 1
fi

echo
echo "4) Submit correct flag for ch1"
GOOD_FLAG="flag{welcome_to_ssh}"

RESP=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/submit_flag" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"challenge_id\":1,\"flag\":\"$GOOD_FLAG\"}")

CODE=$(echo "$RESP" | tail -n1)
BODY=$(echo "$RESP" | head -n-1)

echo "Status: $CODE | Body:"
echo "$BODY" | jq .

if [ "$CODE" != "200" ] || [ "$(echo "$BODY" | jq -r '.correct')" != "true" ]; then
  echo "Correct-flag submission failed"; exit 1
fi

echo
echo "5) Check leaderboard"
LB=$(curl -s "$BASE_URL/api/leaderboard" -H "Authorization: Bearer $TOKEN")
echo "$LB" | jq .
POINTS=$(echo "$LB" | jq -r ".[] | select(.username==\"$USER\") | .score")
if [ -z "$POINTS" ] || [ "$POINTS" = "null" ] || [ "$POINTS" -lt 100 ]; then
  echo "Leaderboard check failed"; exit 1
fi

echo
echo "6) Check user progress"
UP=$(curl -s "$BASE_URL/api/user/progress" -H "Authorization: Bearer $TOKEN")
echo "$UP" | jq .
SOLVED=$(echo "$UP" | jq -r '.solved')
if [ "$SOLVED" != "1" ]; then
  echo "User progress check failed"; exit 1
fi

echo
echo "✅ PASS: User flow E2E complete"
