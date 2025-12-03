# Quick Start Guide for AI v4.0

**Estimated Time:** 10 minutes | **Last Updated:** 2025-11-29

---

## Step 1: Load Context (1 min)

**Copy-paste at start of new session:**

```
Initializing CyberForge v4 context...

Load these 4 files:
1. CYBERFORGE_MASTER_PROMPT_v4.md (initialization + commands)
2. CYBERFORGE_KNOWLEDGE_BASE_v4.md (architecture + verified state)
3. CYBERFORGE_WORKING_PROTOCOLS_v4.md (procedures + safety)
4. QUICK_START_AI_v4.md (this file)

Status as of 2025-11-29 22:43 UTC:
- Backend: Running on http://localhost:5000 ✓
- Docker: 3+ containers RUNNING (ch1, ch2, ch3) ✓
- Git: Latest commit 8702241 - "fix: backend auth and leaderboard flow" ✓
- Tests: All smoke tests pass ✓
- SSH ch1: Verified ctfuser/password123 → flag{welcome_to_cyberforge_1} ✓
```

---

## Step 2: Verify Environment (2 min)

**Run this command immediately:**

```bash
cd ~/Documents/cyberforge && \
echo "=== GIT ===" && git log --oneline -1 && \
echo -e "\n=== DOCKER ===" && docker compose ps && \
echo -e "\n=== BACKEND ===" && curl -s http://localhost:5000/api/health | jq . && \
echo -e "\n=== CHALLENGES ===" && curl -s http://localhost:5000/api/challenges | jq '.[] | .id' && \
echo -e "\n✓ Environment verified"
```

**Expected output:**
```
=== GIT ===
8702241 fix: backend auth and leaderboard flow

=== DOCKER ===
cyberforge-backend    Running
cyberforge-website    Running
cyberforge-ch1        Running
...

=== BACKEND ===
{
  "message": "Backend is running",
  "status": "OK"
}

=== CHALLENGES ===
1
2
3

✓ Environment verified
```

If any step fails → Restart Docker: `docker compose down && docker compose up -d && sleep 5`

---

## Step 3: Quick Smoke Test (3 min)

**Test complete user flow (register → login → submit → leaderboard):**

```bash
cd ~/Documents/cyberforge && \
TEST_USER="smoketest_$(date +%s)" && \
TEST_PASS="Pass123" && \
\
echo "1. Register:" && \
REG=$(curl -s -X POST http://localhost:5000/api/register \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$TEST_USER\",\"email\":\"$TEST_USER@test.local\",\"password\":\"$TEST_PASS\"}") && \
echo "$REG" | jq . && \
\
echo -e "\n2. Login:" && \
LOGIN=$(curl -s -X POST http://localhost:5000/api/login \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$TEST_USER\",\"password\":\"$TEST_PASS\"}") && \
TOKEN=$(echo "$LOGIN" | jq -r '.access_token') && \
echo "Token: ${TOKEN:0:20}..." && \
\
echo -e "\n3. Submit Flag:" && \
SUBMIT=$(curl -s -X POST http://localhost:5000/api/submit_flag \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"challenge_id":1,"flag":"flag{welcome_to_cyberforge_1}"}') && \
echo "$SUBMIT" | jq . && \
\
echo -e "\n4. Check Leaderboard:" && \
curl -s http://localhost:5000/api/leaderboard \
  -H "Authorization: Bearer $TOKEN" | jq ".[] | select(.username==\"$TEST_USER\")" && \
\
echo -e "\n✓ Smoke test complete"
```

**Expected result:** New user appears in leaderboard with 100 points and `solved: 1`.

---

## Step 4: Verify SSH Challenge (2 min)

**Test Challenge 1 SSH access:**

```bash
echo "Testing SSH to ch1..."
ssh -p 2222 ctfuser@localhost <<< "cat ~/challenge/flag.txt"
# When prompted for password, type: password123
# Expected output: flag{welcome_to_cyberforge_1}
```

---

## Step 5: Check Current Status (1 min)

**Get a quick status report:**

```bash
cd ~/Documents/cyberforge && \
TOKEN=$(curl -s -X POST http://localhost:5000/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"user2","password":"Pass123"}' | jq -r '.access_token') && \
\
echo "=== BACKEND ===" && \
curl -s http://localhost:5000/api/health | jq . && \
\
echo -e "\n=== LEADERBOARD ===" && \
curl -s http://localhost:5000/api/leaderboard \
  -H "Authorization: Bearer $TOKEN" | jq . && \
\
echo -e "\n=== GIT ===" && \
git status --short && \
git log --oneline -1
```

---

## Common Commands (Reference)

### Backend Health
```bash
curl http://localhost:5000/api/health | jq .
```

### List All Challenges
```bash
curl http://localhost:5000/api/challenges | jq .
```

### View Leaderboard
```bash
TOKEN=$(curl -s -X POST http://localhost:5000/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"user2","password":"Pass123"}' | jq -r '.access_token') && \
curl -s http://localhost:5000/api/leaderboard \
  -H "Authorization: Bearer $TOKEN" | jq .
```

### Restart All Services
```bash
docker compose down && docker compose up -d && sleep 5 && echo "✓ Restarted"
```

### View Backend Logs
```bash
docker compose logs backend --tail=30 -f
```

### SSH to Challenge 1
```bash
ssh -p 2222 ctfuser@localhost
# password: password123
```

### Git Status
```bash
git status && git log --oneline -3
```

### Make a Commit
```bash
git add [files] && \
git commit -m "type: description" && \
git push origin main
```

---

## Approved Test Credentials

| User | Password | Notes |
|------|----------|-------|
| user2 | Pass123 | Main test user (100 points) |
| apitest | Pass123 | API test user (100 points) |
| testadmin | Pass123 | Admin testing |
| admin | Pass123 | Production admin |

**SSH Credentials:**
- Username: `ctfuser`
- Password: `password123`

---

## If Something Breaks

| Symptom | Solution |
|---------|----------|
| Backend returns 500 | `docker compose logs backend \| tail -20` |
| Containers won't start | `docker compose down && docker compose up -d` |
| SSH connection refused | `docker compose ps \| grep ch1` (check if running) |
| Token not working | Generate new token: `curl -X POST http://localhost:5000/api/login ...` |
| Database error | `rm backend/cyberforge.db && docker compose restart backend` |

---

## Next Steps

After quick start is verified:

1. **For new features:** See CYBERFORGE_WORKING_PROTOCOLS_v4.md → Change Proposal Template
2. **For debugging:** See CYBERFORGE_KNOWLEDGE_BASE_v4.md → Known Issues section
3. **For full context:** Read CYBERFORGE_MASTER_PROMPT_v4.md → All 6 phases
4. **For SSH testing:** Test ch2 and ch3 (currently untested)

---

## Session Handoff Template

When ending session, copy this template and fill in:

```
## Session Closure Summary (CyberForge v4)
**Session Duration:** [Start–End times]
**AI Model:** [Model name]

### Commitments Made
- [Brief description of changes]
- [Commits created: N]
- [Tests passed: Y/N]

### Current State
- Git HEAD: [commit hash and message]
- Backend: [Running/Stopped]
- Tests: [X/Y passing]
- SSH ch1: [Verified/Not tested]

### Risks / TODOs
- [ ] [If any pending item]
- [ ] [If any known issue]

### Next AI Should
1. Run Step 1–2 of QUICK_START_AI_v4.md
2. Then proceed with: [Next planned task]

**Ready for handoff:** Yes ✓
```

---

**Questions?** Check CYBERFORGE_MASTER_PROMPT_v4.md Phase 6 (Escalation Path).
