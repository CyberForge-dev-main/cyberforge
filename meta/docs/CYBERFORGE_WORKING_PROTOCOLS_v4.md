CyberForge Operational Protocols v4.0

Version: 4.0
Last Updated: 2025-12-03
Status: Production Guidelines

PRE-CHANGE CHECKLIST

Before ANY code/config modification execute these checks:

git status shows less than 5 uncommitted changes acceptable: venv node_modules .env
git log --oneline -3 confirms expected last commits
docker compose ps shows all containers RUNNING or HEALTHY
curl http://localhost:5000/api/health returns 200
Current branch is main
No pending merge conflicts: git diff --name-only --diff-filter=U

Quick Pre-Check Command:
cd ~/Documents/cyberforge && echo "Git:" && git status --short && echo -e "\nDocker:" && docker compose ps --no-trunc | grep -E "RUNNING|HEALTHY|STOPPED" && echo -e "\nBackend:" && curl -s http://localhost:5000/api/health | jq '.status'

POST-CHANGE CHECKLIST

After making changes before committing execute these checks:

Code compiles no syntax errors
Affected tests still pass
git diff shows ONLY intended changes no accidental files
No hardcoded credentials or secrets in diff
Comments added for non-obvious logic
Related files in meta/docs updated if API endpoint changed
Run ./test.sh to verify all tests pass

Diff Review Command:
git diff --stat && git diff -- '*.py' '*.md' '*.yml' | head -100

COMMIT STANDARDS

Format: type: brief description max 50 chars

Types:
fix: Bug fix
feat: New feature
docs: Documentation only
chore: Dependencies tooling cleanup
refactor: Code restructuring no logic change
test: Test additions/fixes

Examples GOOD:
fix: backend auth and leaderboard flow
feat: add rate limiting to /api/submit_flag
docs: update SSH credentials in knowledge base
chore: bump flask to 2.4.0
test: add rate-limit verification for submit_flag endpoint

Examples BAD:
fix backend
Updated code
WIP: trying to fix something
minor changes
stuff

Full Workflow:
cd ~/Documents/cyberforge && git status && git diff --stat && git add [modified_files] && git commit -m "type: description" && git status && git log --oneline -1

ESCALATION PROTOCOL

If something breaks during development:

Issue: Backend returns 500
Action: Check docker compose logs backend
Escalation Level: Level 1 Check logs

Issue: Docker container won't start
Action: docker compose logs [service] check Dockerfile
Escalation Level: Level 1 Check logs

Issue: Git merge conflict
Action: Check conflicting files resolve manually test
Escalation Level: Level 2 Manual intervention

Issue: Database corruption
Action: Restore from backup OR recreate lose test data
Escalation Level: Level 2 Data loss risk

Issue: API endpoint crashes consistently
Action: Review code in backend/app.py trace error
Escalation Level: Level 2 Code review

Issue: Challenge container SSH fails
Action: Verify Dockerfile SSH config test manually
Escalation Level: Level 2 Config review

Issue: Unclear if safe to proceed
Action: Ask for explicit approval message
Escalation Level: Level 3 Human approval required

Debug Command Sequence:
Step 1: Check all services
docker compose ps

Step 2: View backend logs
docker compose logs backend --tail=50

Step 3: Test endpoint manually
curl -s http://localhost:5000/api/health | jq .

Step 4: Check git state
git status && git diff --stat

Step 5: Restart if needed
docker compose down && docker compose up -d && sleep 5

CHANGE PROPOSAL TEMPLATE

For any change affecting more than 2 files or more than 50 lines:

Change Proposal: Clear Title

Problem:
Describe what's broken or what needs improvement

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

GIT PRACTICES

Branch Strategy:
main: Production always stable only commits with verified tests
feature/*: Feature branches not used in current solo dev but standard
No git rebase on main use git merge only

Commit Frequency:
Small changes bug fixes: 1 commit per fix
Features: 1 to 3 commits logical grouping
Avoid: WIP temp debug commits on main

Push Protocol:
Before pushing ensure:
git log --oneline origin/main..main See what's new locally
git diff origin/main -- backend/ Review backend changes
git push origin main Only after review

TESTING CADENCE

After each commit run:

Smoke Test 2 min:
curl -s http://localhost:5000/api/health | jq .

API Health Check 3 min:
cd ~/Documents/cyberforge && echo "Challenges:" && curl -s http://localhost:5000/api/challenges | jq '.[] | .id' && echo "Leaderboard:" && curl -s -H "Authorization: Bearer $(curl -s -X POST http://localhost:5000/api/login -H "Content-Type: application/json" -d '{"username":"user2","password":"Pass123"}' | jq -r '.access_token')" http://localhost:5000/api/leaderboard | jq 'length'

SSH Spot Check 2 min ch1 only:
ssh -p 2222 ctfuser@localhost
Inside: cat ~/challenge/flag.txt
exit

Full Test Suite:
cd ~/Documents/cyberforge
./test.sh

Full Test Suite with Snapshot:
cd ~/Documents/cyberforge
./run_tests_and_snapshot.sh

ROLLBACK PROCEDURES

If a commit breaks production:

Option 1: Revert last commit creates new commit
git revert HEAD --no-edit && git push origin main

Option 2: Soft reset undo locally re-commit with fix
git reset --soft HEAD~1 && git status

Option 3: Hard reset to known-good state DANGER loses changes
git reset --hard origin/main~1 && git push --force-with-lease origin main

Recovery Priority:
1. Restore backend health
2. Verify databases intact
3. Re-run smoke tests
4. Communicate status

WEEKLY CHECKLIST

Every 5 to 7 days:

git log --oneline main shows reasonable commit history no spam
All test users still have correct points verify in /api/leaderboard
SSH ch1 to ch3 manually tested at least once
Database size reasonable ls -lh backend/cyberforge.db
Docker images up-to-date docker images
No stale branches cluttering repo
Review logs/ai_actions.log for patterns
Check snapshots/context_snapshot_FULL.txt is recent

Maintenance Command:
cd ~/Documents/cyberforge && echo "=== GIT HEALTH ===" && git log --oneline -5 && echo -e "\n=== DOCKER HEALTH ===" && docker compose ps && echo -e "\n=== DB SIZE ===" && ls -lh backend/cyberforge.db && echo -e "\n=== LEADERBOARD STATE ===" && curl -s -H "Authorization: Bearer $(curl -s -X POST http://localhost:5000/api/login -H "Content-Type: application/json" -d '{"username":"user2","password":"Pass123"}' | jq -r '.access_token')" http://localhost:5000/api/leaderboard | jq .

PROHIBITED ACTIONS

Never:
Commit to main with failing tests
Use git rebase on main
Modify SSH challenge Dockerfiles without explicit approval
Push unreviewed database migrations
Leave debug prints in production code
Expose credentials in git history
Force-push to main use --force-with-lease only in emergency
Run commands as root unnecessarily
Skip the pre-change checklist
Modify .env without backup
Delete logs without archiving
Change docker-compose.yml without testing locally first

APPROVED TEST ACCOUNTS

Username: user2
Password: Pass123
Purpose: Main test user
Points: 100 ch1
Created: 2025-11-29

Username: apitest
Password: Pass123
Purpose: API integration tests
Points: 100 ch1
Created: 2025-11-29

Username: testadmin
Password: Pass123
Purpose: Admin testing
Points: 0
Created: 2025-11-29

Username: admin
Password: Pass123
Purpose: Production admin
Points: 0
Created: Initial
Note: DO NOT USE FOR TESTING

SSH Credentials:
Username: ctfuser
Password: password123
Ports: 2222 ch1 2223 ch2 2224 ch3
Note: ch1 verified ch2 and ch3 pending verification

FILE MODIFICATION APPROVAL MATRIX

File Type: Configuration Files
Examples: docker-compose.yml .env backend/config.py
Approval Required: Yes explicit
Risk Level: High
Reason: Can break entire system

File Type: Database Schema
Examples: backend/models.py
Approval Required: Yes explicit
Risk Level: High
Reason: Can cause data loss or corruption

File Type: Dockerfiles
Examples: challenges/ch1/Dockerfile challenges/ch2/Dockerfile challenges/ch3/Dockerfile
Approval Required: Yes explicit
Risk Level: Medium
Reason: Changes affect challenge containers

File Type: API Endpoints
Examples: backend/app.py backend/auth.py
Approval Required: Yes if breaking changes
Risk Level: Medium
Reason: Can break frontend or tests

File Type: Tests
Examples: tests/*.sh
Approval Required: No
Risk Level: Low
Reason: Isolated changes

File Type: Documentation
Examples: meta/docs/*.md README.md
Approval Required: No
Risk Level: Low
Reason: No code impact

File Type: Scripts
Examples: scripts/*.sh
Approval Required: No unless affects CI/CD
Risk Level: Low to Medium
Reason: Depends on script purpose

TESTING REQUIREMENTS BY CHANGE TYPE

Change Type: API Endpoint Modification
Required Tests:
Run ./test.sh full suite
Test affected endpoint manually with curl
Verify JWT token handling if auth endpoint
Check rate limiting if applicable
Verify error responses

Change Type: Database Schema Change
Required Tests:
Backup database before change
Test with fresh database
Test with existing data
Verify migrations if applicable
Check foreign key constraints

Change Type: Docker Configuration Change
Required Tests:
docker compose down && docker compose up -d
Verify all containers start
Check logs for errors: docker compose logs
Test inter-container communication
Verify port bindings: netstat -tuln

Change Type: SSH Challenge Change
Required Tests:
SSH into container manually
Verify flag file exists and is readable
Test with correct credentials
Test with incorrect credentials
Verify port accessibility from host

Change Type: Frontend Change
Required Tests:
Load page in browser
Test all interactive elements
Verify API calls succeed
Check console for errors
Test on mobile viewport if responsive

LOGGING STANDARDS

Log Levels:
ERROR: System failures that require immediate attention
WARN: Potential issues that should be monitored
INFO: Important state changes and operations
DEBUG: Detailed information for troubleshooting

Log Format:
[TIMESTAMP] [LEVEL] [COMPONENT] MESSAGE

Example:
[2025-12-03T16:26:17+03:00] [INFO] [backend] User user2 logged in successfully
[2025-12-03T16:26:18+03:00] [WARN] [backend] Rate limit approached for user user2
[2025-12-03T16:26:19+03:00] [ERROR] [backend] Database connection failed

Log Files:
logs/ai_actions.log: AI actions and decisions
logs/context_history.log: Context snapshots over time
backend logs: docker compose logs backend

Log Rotation:
Manual: Archive logs monthly to archive/logs/YYYY-MM/
Automatic: Not yet implemented

SNAPSHOT AND CONTEXT MANAGEMENT

Context Snapshot Frequency:
After every test run via ./run_tests_and_snapshot.sh
Before major changes manually via ./scripts/save_full_context.sh
After completing features
When git state changes significantly

Snapshot Contents:
Git: branch current commit last 5 commits status
Docker: container status ports resource usage
Backend: health check challenges count
Tests: last test output summary pass/fail counts
File structure: filtered tree excluding .git venv node_modules

Snapshot Location:
snapshots/context_snapshot_FULL.txt: Latest full snapshot
Overwritten on each snapshot

Snapshot Usage:
Attach to new AI sessions for full context
Review project state at specific points in time
Troubleshoot issues by comparing snapshots
Document project evolution

CONTACT AND ESCALATION

Level 1: Self-Service
Check logs: docker compose logs [service]
Review CYBERFORGE_KNOWLEDGE_BASE_v4.md for similar issues
Run diagnostic commands from MASTER_PROMPT_v4.md
Check last_test_output.log for test failures

Level 2: Documentation Review
Review CYBERFORGE_WORKING_PROTOCOLS_v4.md for procedures
Check QUICK_START_AI_v4.md for quick fixes
Review snapshots/context_snapshot_FULL.txt for recent changes
Search archive/ for similar past issues

Level 3: Human Approval
Ask for explicit confirmation before risky operations
Propose changes using Change Proposal Template
Wait for approval before proceeding with:
Database migrations
Docker configuration changes
Breaking API changes
Force-push operations

BACKUP PROCEDURES

Database Backup:
Manual: cp backend/cyberforge.db backend/cyberforge.db.backup.YYYY-MM-DD
Frequency: Before schema changes before major features monthly
Retention: Keep last 3 monthly backups

Configuration Backup:
Manual: cp .env .env.backup && cp docker-compose.yml docker-compose.yml.backup
Frequency: Before modifications
Retention: Keep in archive/backups/

Code Backup:
Method: Git repository
Frequency: On every commit
Location: GitHub https://github.com/CyberForge-dev-main/cyberforge
Retention: Indefinite via git history

Snapshot Backup:
Method: Context snapshots
Frequency: After test runs after major changes
Location: snapshots/ directory
Retention: Keep last 10 snapshots archive older ones

Recovery Procedures:
Database: rm backend/cyberforge.db && cp backend/cyberforge.db.backup.YYYY-MM-DD backend/cyberforge.db && docker compose restart backend
Configuration: cp .env.backup .env && cp docker-compose.yml.backup docker-compose.yml && docker compose down && docker compose up -d
Code: git reset --hard [commit_hash] or git revert [commit_hash]

END OF WORKING_PROTOCOLS_v4.md
