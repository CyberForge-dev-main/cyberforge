#!/bin/bash
# CyberForge Smoke Test (FINAL FIX)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🧪 CyberForge Smoke Test"
echo "========================"
echo ""

PASS=0
FAIL=0

test() {
  echo -n "[$1] "
  shift
  if eval "$@" > /dev/null 2>&1; then
    echo -e "${GREEN}PASS${NC}"
    ((PASS++))
  else
    echo -e "${RED}FAIL${NC}"
    ((FAIL++))
  fi
}

# Infrastructure Tests
echo "Infrastructure:"
test "Backend health" 'curl -sf http://localhost:5000/api/health'
test "Website accessible" 'curl -sf http://localhost:3000 | grep -q DOCTYPE'
test "Juice Shop running" 'curl -sf http://localhost:3001 | grep -q Juice'
test "SSH ch1 port" 'nc -zv localhost 2222 2>&1 | grep -q succeeded'
test "SSH ch2 port" 'nc -zv localhost 2223 2>&1 | grep -q succeeded'
test "SSH ch3 port" 'nc -zv localhost 2224 2>&1 | grep -q succeeded'
echo ""

# API Tests
echo "API:"
test "Get challenges" 'curl -sf http://localhost:5000/api/challenges | jq -e "length >= 3"'

TESTUSER="smoketest_$(date +%s)"
TESTEMAIL="$TESTUSER@test.local"
test "Register user" 'curl -sf -X POST http://localhost:5000/api/register -H "Content-Type: application/json" -d "{\"username\":\"'$TESTUSER'\",\"email\":\"'$TESTEMAIL'\",\"password\":\"Pass123\"}"'

TOKEN=$(curl -sf -X POST http://localhost:5000/api/login -H "Content-Type: application/json" -d '{"username":"'$TESTUSER'","password":"Pass123"}' | jq -r '.token')
test "Login user" '[ ! -z "$TOKEN" ] && [ "$TOKEN" != "null" ]'

test "Submit flag" 'curl -sf -X POST http://localhost:5000/api/submit_flag -H "Content-Type: application/json" -H "Authorization: Bearer '$TOKEN'" -d "{\"challenge_id\":1,\"flag\":\"flag{welcome_to_ssh}\"}" | jq -e ".success == true"'

test "Leaderboard" 'curl -sf http://localhost:5000/api/leaderboard | jq -e "type == \"array\""'
echo ""

# SSH Tests (FIXED: правильный пароль и пути)
echo "SSH Challenges:"
test "SSH ch1 flag" 'sshpass -p password123 ssh -o StrictHostKeyChecking=no -p 2222 ctfuser@localhost "cat ~/challenge/flag.txt" 2>/dev/null | grep -q "flag{welcome_to_ssh}"'
test "SSH ch2 flag" 'sshpass -p password123 ssh -o StrictHostKeyChecking=no -p 2223 ctfuser@localhost "cat ~/challenge/.hidden_flag" 2>/dev/null | grep -q "flag{hidden_treasure}"'
test "SSH ch3 flag" 'docker exec cyberforge-ch3 cat /home/ctfuser/challenge/flag.txt 2>/dev/null | grep -q "flag{env_secrets}"'
echo ""

# Summary
echo "========================"
echo -e "Results: ${GREEN}$PASS passed${NC}, ${RED}$FAIL failed${NC}"
echo ""
if [ $FAIL -eq 0 ]; then
  echo -e "${GREEN}✅ ALL TESTS PASSED!${NC}"
  exit 0
else
  echo -e "${YELLOW}⚠️  Some tests failed${NC}"
  exit 1
fi
