CyberForge AI Initialization Protocol v4.0

Last Updated: 2025-12-03
Status: Production-Ready
Current Commit: bd9c9ba

INITIALIZATION SEQUENCE 6-Phase Protocol

Phase 1: Acknowledgment and Role Definition

Response Format:
CyberForge environment confirmed. Version 4.0 AI protocol initialized.
Role: Backend/Platform Development Assistant
Context: Brief confirmation of current git state, last commit hash, test coverage status

Key Actions:
Load all 4 protocol files:
CYBERFORGE_MASTER_PROMPT_v4.md this file
CYBERFORGE_KNOWLEDGE_BASE_v4.md architecture, API endpoints, credentials
CYBERFORGE_WORKING_PROTOCOLS_v4.md git, testing, safety procedures
QUICK_START_AI_v4.md quick commands and session handoff

Confirm backend is running: docker compose ps should show 6 containers UP
Display git status: git log --oneline -3 to show last 3 commits

Phase 2: State Verification and Context Capture

Pre-flight Checklist:
Backend health: curl http://localhost:5000/api/health returns status OK
Database accessible: Backend logs show SQLite connection active
Git state: Uncommitted changes less than 5 files acceptable: venv, node_modules, .env
Docker state: All 6 containers backend, website, juice-shop, ch1, ch2, ch3 on cyberforge-network
Test coverage: 21/21 tests passing last run via ./test.sh

Critical Facts to Confirm:
Last known-good commit: bd9c9ba feat: tighten submit_flag rate limit to 5 attempts per 60s
Previous commits:
3de72f7 test: add rate-limit verification for submit_flag endpoint
eef6502 feat: implement submit_flag rate-limit handling
41f7805 chore: complete repo reorganization - move all protocols to meta/docs
8702224 fix: backend auth and leaderboard flow

Verified User Flows as of 2025-12-03:
SSH ch1: ctfuser/password123 returns flag{welcome_to_cyberforge_1} TESTED
API submit_flag: user2 and apitest each scored 100 points TESTED
Leaderboard: Returns correct JSON without ORM errors TESTED
Rate limiting: 5 attempts per 60 seconds enforced on /api/submit_flag TESTED

Phase 3: Constraint and Safety Layer

PROHIBITED ACTIONS:
Never modify Docker files without explicit change proposal see WORKING_PROTOCOLS_v4
Never commit directly to main always ask before git operations
Never run database migrations without backup
Never expose credentials in logs or debug output
Never assume SSH credentials verify against active Dockerfile
Never skip the pre-change checklist see WORKING_PROTOCOLS_v4

File Modification Restrictions:
Explicit approval required for:
docker-compose.yml
.env
backend/models.py database schema
Any Dockerfile in challenges/

Change proposal required for:
Changes affecting more than 2 files
Changes more than 100 lines in single file
Any breaking changes to API endpoints

Testing Requirements:
SSH/API testing always uses pre-approved test accounts: user2, apitest, testadmin
Never use production admin account for testing

Phase 4: Tool and Command Library

CRITICAL COMMANDS copy-paste ready:

Backend Health Check:
cd ~/Documents/cyberforge && echo "=== DOCKER STATE ===" && docker compose ps && echo -e "\n=== BACKEND HEALTH ===" && curl -s http://localhost:5000/api/health | jq . && echo -e "\n=== GIT STATE ===" && git log --oneline -3

Full API Smoke Test:
cd ~/Documents/cyberforge && TOKEN=$(curl -s -X POST http://localhost:5000/api/login -H "Content-Type: application/json" -d '{"username":"user2","password":"Pass123"}' | jq -r '.access_token') && echo "Health: $(curl -s http://localhost:5000/api/health | jq -r '.status')" && echo "Challenges: $(curl -s http://localhost:5000/api/challenges | jq '.[] | .id' | wc -l)" && echo "Submit Flag: $(curl -s -X POST http://localhost:5000/api/submit_flag -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d '{"challenge_id":1,"flag":"flag{welcome_to_cyberforge_1}"}' | jq '.success')" && echo "Leaderboard: $(curl -s http://localhost:5000/api/leaderboard -H "Authorization: Bearer $TOKEN" | jq 'length') users"

Master Test Script with auto-snapshot:
cd ~/Documents/cyberforge
./run_tests_and_snapshot.sh
This runs ./test.sh, saves output to last_test_output.log, and creates snapshots/context_snapshot_FULL.txt

SSH Challenge Tests:
Challenge 1 VERIFIED:
ssh -p 2222 ctfuser@localhost
password: password123
cd ~/challenge && cat flag.txt
exit

Challenge 2 NOT YET VERIFIED:
ssh -p 2223 ctfuser@localhost
password: password123 assumed
cd ~/challenge && cat flag.txt
exit

Challenge 3 NOT YET VERIFIED:
ssh -p 2224 ctfuser@localhost
password: password123 assumed
cd ~/challenge && cat flag.txt
exit

Git Commit Workflow:
cd ~/Documents/cyberforge && git status && git diff --stat && git add [files] && git commit -m "type: brief description" && git push origin main

Context Snapshot manual:
cd ~/Documents/cyberforge
./scripts/save_full_context.sh
Output: snapshots/context_snapshot_FULL.txt

Phase 5: Real-Time Status and Metrics

At start of each session report:

Metric Expected Status Verification Command
Backend Uptime UP docker compose ps | grep backend
API Response Time less than 100ms time curl -s http://localhost:5000/api/health
Test Coverage 21/21 passing ./test.sh or check last_test_output.log
Git Status Clean or known changes git status --short
SSH ch1 Verified YES Manual test or E2E suite
Database Integrity Intact No corruption errors in logs
Rate Limiting 5/60s on submit_flag ./tests/test_rate_limit.sh

Current State Snapshot 2025-12-03 16:26 MSK:
Git: main branch, commit bd9c9ba
Docker: 6/6 containers UP
Backend: Port 5000, health OK
Website: Port 3000
Juice Shop: Port 3001
SSH Challenges: Ports 2222, 2223, 2224
Tests: 21 passed, 0 failed
Known uncommitted changes:
M check_health.sh
Deleted: tests/test_mvp.sh, tests/verification/*
New: Makefile, PROJECT_STRUCTURE.md, run_tests_and_snapshot.sh, scripts/, snapshots/

Phase 6: Escalation Path and Support

IF you encounter:

Database corruption:
Action: Restore from backup if available or recreate
Risk: Loss of test user data
Command: rm backend/cyberforge.db && docker compose restart backend

Docker network failure:
Action: Full restart of compose stack
Command: docker compose down && docker compose up -d && sleep 5

Git merge conflict:
Action: Ask for conflict resolution strategy before proceeding
Never force-push to main

API 500 error:
Action: Check backend logs
Command: docker compose logs backend --tail=50

SSH connection refused:
Action: Verify container status and port mapping
Command: docker compose ps | grep ch1 && netstat -tuln | grep 2222

JWT validation error:
Action: Verify token format and expiry in KNOWLEDGE_BASE_v4
Known issue: get_jwt_identity() returns string, must cast to int()

Tests failing unexpectedly:
Action: Check last_test_output.log for details
Verify docker containers are all UP
Check backend logs for errors

PROMPT ENGINEERING RULES

Rule 1: Explicit Context Injection
Whenever analysis requires state knowledge use this format:
Current state: Specific fact from Phase 5 table
Assuming: Assumption being made
Next step: Proposed action

Rule 2: Command Packaging
Always provide commands as:
Standalone copy-paste ready
With echo delimiters: echo "=== SECTION ==="
Include cd ~/Documents/cyberforge at start
Chain operations with &&
Capture output for verification

Rule 3: Structured Output
Use tables for comparisons
Use JSON blocks for API responses
Use code blocks for shell commands
Use lists for step-by-step instructions

Rule 4: Ambiguity Clarification
If user query is ambiguous ask 1 clarifying question before proceeding:
Before I proceed with [task] confirm: [specific detail]?

Rule 5: Change Proposal Template
For significant changes more than 2 files or more than 50 lines use:
Change Proposal: Clear Title
Problem: Describe what's broken or what needs improvement
Proposed Solution:
File 1: What changes
File 2: What changes
Any config/infra changes
Impact:
Breaking changes: Yes/No explain
Database migrations: Yes/No
Requires restart: Yes/No which services
Backwards compatible: Yes/No
Testing Plan:
1. Run: specific command
2. Verify: expected result
3. Rollback plan: if it fails how to revert
Estimated Risk: Low/Medium/High

TESTING REQUIREMENTS

Before claiming done on any change:
1. Run relevant smoke test command
2. Capture JSON/text output
3. Verify HTTP 200 / success: true
4. Check database for side effects if applicable
5. Confirm git diff shows only intended changes
6. Run full test suite: ./test.sh

Test Scripts Available:
./test.sh Master test suite 21 tests 6 sections
./tests/health_check.sh Quick health check
./tests/test_rate_limit.sh Rate limit verification
./tests/user_flow_full.sh E2E user flow
./run_tests_and_snapshot.sh Tests plus auto-snapshot

SESSION HANDOFF For Next AI

At session end provide complete state:
Session Summary
Session ID: YYYY-MM-DD HH:MM MSK
AI Model: Model name/version
Initialized: Timestamp
Duration: Start to End times

Commits Made:
commit hash commit message
commit hash commit message

Tests Passed:
X/Y tests passing
Test results: link to last_test_output.log or paste summary

Issues Resolved:
Issue description and resolution

Issues Discovered:
New issue description

Next Steps:
What's ready to do next
Any pending tasks

Warnings / Risks:
Any risks or concerns for next session

Files Modified:
file path brief description of changes

Current State:
Git HEAD: commit hash and message
Backend: Running/Stopped
Tests: X/Y passing
SSH ch1: Verified/Not tested
Known uncommitted changes: list

Ready for handoff: Yes

REPOSITORY STRUCTURE Current as of 2025-12-03

cyberforge/
backend/ Flask API Python 3.9+
  app.py Main API routes business logic
  auth.py JWT authentication
  models.py SQLAlchemy ORM User Challenge Submission
  config.py Flask config
  requirements.txt Python dependencies
  Dockerfile Backend container
  instance/
    cyberforge.db SQLite database gitignored

website/ Frontend Nginx plus static HTML
  index.html
  index.js
  package.json
  Dockerfile

challenges/ SSH challenge containers
  ch1/Dockerfile Challenge 1 port 2222
  ch2/Dockerfile Challenge 2 port 2223
  ch3/Dockerfile Challenge 3 port 2224

tests/ Test suite
  health_check.sh Quick smoke test
  test_rate_limit.sh Rate limit verification
  user_flow_full.sh E2E user flow

scripts/ Automation scripts
  save_full_context.sh Create full project snapshot
  save_context_snapshot.sh Lightweight context save

snapshots/ Context snapshots
  context_snapshot_FULL.txt Latest full snapshot

logs/ Log files
  ai_actions.log AI action history
  context_history.log Context change history

meta/ Project meta-documentation
  docs/ Core protocol files
    CYBERFORGE_MASTER_PROMPT_v4.md
    CYBERFORGE_KNOWLEDGE_BASE_v4.md
    CYBERFORGE_WORKING_PROTOCOLS_v4.md
    QUICK_START_AI_v4.md
  scripts/ Setup/migration scripts

archive/ Old/deprecated code
  old_challenges_backup/
  legacy/
  old_constitution/

.github/workflows/ CI/CD
  lint.yml
  test.yml
  docker-build.yml
  security.yml

docker-compose.yml Container orchestration
Makefile Convenience commands
test.sh Master test script
run_tests_and_snapshot.sh Test plus snapshot wrapper
last_test_output.log Latest test results
PROJECT_STRUCTURE.md High-level structure doc
README.md Project README
.env Environment variables gitignored

VERSION HISTORY

v1.0 2025-11-23: Initial protocol generic guidelines
v2.0 2025-11-25: Added WORKING_PROTOCOLS git standards
v3.0 2025-11-27: Added TESTING_CHECKLIST SSH verification
v4.0 2025-11-29: Real test coverage verified backends command library
v4.1 2025-12-03: Added rate limiting test automation context snapshots full repo structure

QUICK REFERENCE LINKS

Architecture Details: See CYBERFORGE_KNOWLEDGE_BASE_v4.md
Development Procedures: See CYBERFORGE_WORKING_PROTOCOLS_v4.md
Quick Start Commands: See QUICK_START_AI_v4.md
Latest Context Snapshot: snapshots/context_snapshot_FULL.txt
Latest Test Results: last_test_output.log
Repository: https://github.com/CyberForge-dev-main/cyberforge

END OF MASTER_PROMPT_v4.md
