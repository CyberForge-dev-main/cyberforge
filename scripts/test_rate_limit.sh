#!/bin/bash
# Test rate limiting on /api/submit_flag
# Expects: 429 after 5 attempts within 60 seconds

set -e

BASE_URL="http://localhost:5000"
TEST_USER="ratelimit_test_$(date +%s)"
TEST_PASS="Pass123"

echo "=== Rate Limit Test for /api/submit_flag ==="

sleep 61 # reset IP-based limiter window
echo

# 1. Register test user
echo "1. Registering test user: $TEST_USER"
curl -s -X POST "$BASE_URL/api/register" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$TEST_USER\",\"email\":\"$TEST_USER@test.local\",\"password\":\"$TEST_PASS\"}" | jq .

# 2. Login to get JWT
echo -e "\n2. Logging in..."
TOKEN=$(curl -s -X POST "$BASE_URL/api/login" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$TEST_USER\",\"password\":\"$TEST_PASS\"}" | jq -r '.access_token')

echo "Token obtained: ${TOKEN:0:20}..."

# 3. Submit flag 5 times (should succeed)
echo -e "\n3. Submitting flag 5 times (should all work)..."
for i in {1..5}; do
  echo "  Attempt $i:"
  RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/submit_flag" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{"challenge_id":1,"flag":"wrong_flag"}')
  
  HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
  BODY=$(echo "$RESPONSE" | head -n1)
  
  echo "    Status: $HTTP_CODE | Response: $BODY"
  
  if [ "$HTTP_CODE" != "200" ] && [ "$HTTP_CODE" != "400" ]; then
    echo "    ⚠️  Unexpected status on attempt $i"
  fi
done

# 4. 6th attempt - should get 429
echo -e "\n4. 6th attempt (should get 429 Too Many Requests)..."
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/submit_flag" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"challenge_id":1,"flag":"wrong_flag"}')

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n1)

echo "  Status: $HTTP_CODE | Response: $BODY"

if [ "$HTTP_CODE" == "429" ]; then
  echo -e "\n✅ PASS: Rate limit triggered correctly (429)"
else
  echo -e "\n❌ FAIL: Expected 429, got $HTTP_CODE"
  exit 1
fi

echo -e "\n=== Test Complete ==="

echo "Cooldown: waiting 65s to avoid cross-test rate-limit interference..."
sleep 65
