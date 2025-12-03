Quick Start Guide for AI v4.0

Estimated Time: 10 minutes
Last Updated: 2025-12-03

Step 1: Load Context 1 min

Copy-paste at start of new session:

Initializing CyberForge v4 context

Load these 4 files:
1. CYBERFORGE_MASTER_PROMPT_v4.md initialization plus commands
2. CYBERFORGE_KNOWLEDGE_BASE_v4.md architecture plus verified state
3. CYBERFORGE_WORKING_PROTOCOLS_v4.md procedures plus safety
4. QUICK_START_AI_v4.md this file

Additionally load if available:
5. snapshots/context_snapshot_FULL.txt latest project snapshot
6. last_test_output.log latest test results

Status as of 2025-12-03:
Backend: Running on http://localhost:5000
Docker: 6 containers RUNNING backend website juice-shop ch1 ch2 ch3
Git: Latest commit bd9c9ba feat: tighten submit_flag rate limit to 5 attempts per 60s
Tests: All 21 tests passing
SSH ch1: Verified ctfuser/password123 returns flag{welcome_to_cyberforge_1}
Rate Limiting: Active 5 attempts per 60 seconds on /api/submit_flag

Step 2: Verify Environment 2 min

Run this command immediately:

cd ~/Documents/cyberforge && echo "=== GIT ===" && git log --oneline -1 && echo -e "\n=== DOCKER ===" && docker compose ps && echo -e "\n=== BACKEND ===" && curl -s http://localhost:5000/api/health | jq . && echo -e "\n=== CHALLENGES ===" && curl -s http://localhost:5000/api/challenges | jq '.[] | .id' && echo -e "\n=== ENVIRONMENT VERIFIED ==="

Expected output:
=== GIT ===
bd9c9ba feat: tighten submit_flag rate limit to 5 attempts per 60s

=== DOCKER ===
cyberforge-backend    Running
cyberforge-website    Running
cyberforge-juice-shop Running
cyberforge-ch1        Running
cyberforge-ch2        Running
cyberforge-ch3        Running

=== BACKEND ===
{
  "message": "Backend is running",
  "status": "OK"
}

=== CHALLENGES ===
1
2
3

=== ENVIRONMENT VERIFIED ===

If any step fails restart Docker:
docker compose down && docker compose up -d && sleep 5

Step 3: Quick Smoke Test 3 min

Test complete user flow register login submit leaderboard:

cd ~/Documents/cyberforge && TEST_USER="smoketest_$(date +%s)" && TEST_PASS="Pass123" && echo "1. Register:" && REG=$(curl -s -X POST http://localhost:5000/api/register -H "Content-Type: application/json" -d "{\"username\":\"$TEST_USER\",\"email\":\"$TEST_USER@test.local\",\"password\":\"$TEST_PASS\"}") && echo "$REG" | jq . && echo -e "\n2. Login:" && LOGIN=$(curl -s -X POST http://localhost:5000/api/login -H "Content-Type: application/json" -d "{\"username\":\"$TEST_USER\",\"password\":\"$TEST_PASS\"}") && TOKEN=$(echo "$LOGIN" | jq -r '.access_token') && echo "Token: ${TOKEN:0:20}..." && echo -e "\n3. Submit Flag:" && SUBMIT=$(curl -s -X POST http://localhost:5000/api/submit_flag -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d '{"challenge_id":1,"flag":"flag{welcome_to_cyberforge_1}"}') && echo "$SUBMIT" | jq . && echo -e "\n4. Check Leaderboard:" && curl -s http://localhost:5000/api/leaderboard -H "Authorization: Bearer $TOKEN" | jq ".[] | select(.username==\"$TEST_USER\")" && echo -e "\n=== SMOKE TEST COMPLETE ==="

Expected result: New user appears in leaderboard with 100 points and solved: 1

Step 4: Verify SSH Challenge 2 min

Test Challenge 1 SSH access:

echo "Testing SSH to ch1..."
ssh -p 2222 ctfuser@localhost
When prompted for password type: password123
Inside container: cat ~/challenge/flag.txt
Expected output: flag{welcome_to_cyberforge_1}
Type exit to leave container

Step 5: Run Full Test Suite 2 min

Run master test script with auto-snapshot:

cd ~/Documents/cyberforge
./run_tests_and_snapshot.sh

This will:
Run all 21 tests across 6 sections
Save output to last_test_output.log
Create snapshots/context_snapshot_FULL.txt
Display pass/fail summary

Expected output:
21 tests passed 0 failed
ALL TESTS PASSED

Step 6: Check Current Status 1 min

Get a quick status report:

cd ~/Documents/cyberforge && TOKEN=$(curl -s -X POST http://localhost:5000/api/login -H "Content-Type: application/json" -d '{"username":"user2","password":"Pass123"}' | jq -r '.access_token') && echo "=== BACKEND ===" && curl -s http://localhost:5000/api/health | jq . && echo -e "\n=== LEADERBOARD ===" && curl -s http://localhost:5000/api/leaderboard -H "Authorization: Bearer $TOKEN" | jq . && echo -e "\n=== GIT ===" && git status --short && git log --oneline -1

COMMON COMMANDS Reference

Backend Health:
curl http://localhost:5000/api/health | jq .

List All Challenges:
curl http://localhost:5000/api/challenges | jq .

View Leaderboard requires token:
TOKEN=$(curl -s -X POST http://localhost:5000/api/login -H "Content-Type: application/json" -d '{"username":"user2","password":"Pass123"}' | jq -r '.access_token')
curl -s http://localhost:5000/api/leaderboard -H "Authorization: Bearer $TOKEN" | jq .

Restart All Services:
docker compose down && docker compose up -d && sleep 5 && echo "Restarted"

View Backend Logs:
docker compose logs backend --tail=30 -f

View All Container Logs:
docker compose logs --tail=50

SSH to Challenge 1:
ssh -p 2222 ctfuser@localhost
password: password123

SSH to Challenge 2:
ssh -p 2223 ctfuser@localhost
password: password123

SSH to Challenge 3:
ssh -p 2224 ctfuser@localhost
password: password123

Git Status:
git status && git log --oneline -3

Git Diff:
git diff --stat

Make a Commit:
git add [files] && git commit -m "type: description" && git push origin main

Run Tests:
./test.sh

Run Tests with Snapshot:
./run_tests_and_snapshot.sh

Create Manual Snapshot:
./scripts/save_full_context.sh

Check Container Status:
docker compose ps

Check Container Resources:
docker stats --no-stream

Check Network Ports:
netstat -tuln | grep -E "5000|3000|3001|2222|2223|2224"

APPROVED TEST CREDENTIALS

API Test Accounts:

Username: user2
Password: Pass123
Notes: Main test user 100 points

Username: apitest
Password: Pass123
Notes: API test user 100 points

Username: testadmin
Password: Pass123
Notes: Admin testing 0 points

Username: admin
Password: Pass123
Notes: Production admin DO NOT USE FOR TESTING

SSH Credentials:

Username: ctfuser
Password: password123
Ports: 2222 ch1 2223 ch2 2224 ch3
Note: ch1 verified ch2 and ch3 pending verification

IF SOMETHING BREAKS

Symptom: Backend returns 500
Solution: docker compose logs backend | tail -20

Symptom: Containers won't start
Solution: docker compose down && docker compose up -d

Symptom: SSH connection refused
Solution: docker compose ps | grep ch1 check if running

Symptom: Token not working
Solution: Generate new token curl -X POST http://localhost:5000/api/login -H "Content-Type: application/json" -d '{"username":"user2","password":"Pass123"}'

Symptom: Database error
Solution: rm backend/cyberforge.db && docker compose restart backend WARNING: loses all data

Symptom: Tests failing
Solution: Check last_test_output.log for details

Symptom: Rate limit error 429
Solution: Wait 60 seconds before retrying

Symptom: Port already in use
Solution: netstat -tuln | grep [port] to find process then kill [pid]

NEXT STEPS

For new features:
See CYBERFORGE_WORKING_PROTOCOLS_v4.md Change Proposal Template

For debugging:
See CYBERFORGE_KNOWLEDGE_BASE_v4.md Known Issues section

For full context:
Read CYBERFORGE_MASTER_PROMPT_v4.md All 6 phases

For SSH testing:
Test ch2 and ch3 currently untested

For rate limiting:
Review tests/test_rate_limit.sh for implementation

For CI/CD:
Review .github/workflows/ for pipeline configuration

SESSION HANDOFF TEMPLATE

When ending session copy this template and fill in:

Session Closure Summary CyberForge v4
Session Duration: Start to End times MSK
AI Model: Model name

Commitments Made:
Brief description of changes
Commits created: N
Tests passed: Y/N

Current State:
Git HEAD: commit hash and message
Backend: Running/Stopped
Tests: X/Y passing
SSH ch1: Verified/Not tested
Docker: X/Y containers UP

Risks / TODOs:
If any pending item
If any known issue

Files Modified:
file path brief description

Next AI Should:
1. Run Step 1 to 2 of QUICK_START_AI_v4.md
2. Then proceed with: Next planned task

Ready for handoff: Yes

TROUBLESHOOTING CHECKLIST

If environment verification fails:

Check Docker daemon is running:
docker ps

Check all containers are up:
docker compose ps

Check backend logs for errors:
docker compose logs backend --tail=50

Check port availability:
netstat -tuln | grep -E "5000|3000|3001|2222|2223|2224"

Restart containers if needed:
docker compose down && docker compose up -d && sleep 5

Verify git state:
git status
git log --oneline -3

Check database file exists:
ls -lh backend/cyberforge.db

Test backend health manually:
curl http://localhost:5000/api/health

If tests fail:

Review last_test_output.log:
cat last_test_output.log | tail -100

Check which section failed:
grep "Failed" last_test_output.log

Run individual test script:
./tests/health_check.sh
./tests/test_rate_limit.sh
./tests/user_flow_full.sh

Verify test dependencies:
command -v docker
command -v docker-compose
command -v python3
command -v jq
command -v curl

QUESTIONS

Check CYBERFORGE_MASTER_PROMPT_v4.md Phase 6 Escalation Path

For architecture questions:
Check CYBERFORGE_KNOWLEDGE_BASE_v4.md

For procedure questions:
Check CYBERFORGE_WORKING_PROTOCOLS_v4.md

For git issues:
Review CYBERFORGE_WORKING_PROTOCOLS_v4.md Git Practices section

For testing issues:
Review CYBERFORGE_WORKING_PROTOCOLS_v4.md Testing Cadence section

For security concerns:
Review CYBERFORGE_KNOWLEDGE_BASE_v4.md Security Considerations section

END OF QUICK_START_AI_v4.md
