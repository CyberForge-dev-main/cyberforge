# CyberForge Operational Protocols v4.0

**Version:** 4.0 | **Last Updated:** 2025-11-29 | **Status:** Production Guidelines

---

## PRE-CHANGE CHECKLIST

**Before ANY code/config modification:**

- [ ] `git status` shows < 5 uncommitted changes (acceptable: venv, node_modules, .env)
- [ ] `git log --oneline -3` confirms expected last commits
- [ ] `docker compose ps` shows all containers RUNNING or HEALTHY
- [ ] `curl http://localhost:5000/api/health` returns 200
- [ ] Current branch is `main`
- [ ] No pending merge conflicts: `git diff --name-only --diff-filter=U`

**Quick Pre-Check Command:**
```bash
cd ~/Documents/cyberforge && \
echo "Git:" && git status --short && \
echo -e "\nDocker:" && docker compose ps --no-trunc | grep -E "RUNNING|HEALTHY|STOPPED" && \
echo -e "\nBackend:" && curl -s http://localhost:5000/api/health | jq '.status'
```

---

## POST-CHANGE CHECKLIST

**After making changes, before committing:**

- [ ] Code compiles (no syntax errors)
- [ ] Affected test(s) still pass
- [ ] `git diff` shows ONLY intended changes (no accidental files)
- [ ] No hardcoded credentials or secrets in diff
- [ ] Comments added for non-obvious logic
- [ ] Related files in `/docs` updated (if API endpoint changed)

**Diff Review Command:**
```bash
git diff --stat && \
git diff -- '*.py' '*.md' '*.yml' | head -100
```

---

## COMMIT STANDARDS

**Format:** `type: brief description (max 50 chars)`

**Types:**
- `fix:` - Bug fix (like today's JWT/leaderboard fixes)
- `feat:` - New feature
- `docs:` - Documentation only
- `chore:` - Dependencies, tooling, cleanup
- `refactor:` - Code restructuring (no logic change)
- `test:` - Test additions/fixes

**Examples:**
```
✓ fix: backend auth and leaderboard flow
✓ feat: add rate limiting to /api/submit_flag
✓ docs: update SSH credentials in knowledge base
✓ chore: bump flask to 2.4.0

✗ fix backend
✗ Updated code
✗ WIP: trying to fix something
```

**Full Workflow:**
```bash
cd ~/Documents/cyberforge && \
git add [modified_files] && \
git commit -m "type: description" && \
git status && \
git log --oneline -1
```

---

## ESCALATION PROTOCOL

**If something breaks during development:**

| Issue | Action | Escalation Level |
|-------|--------|------------------|
| Backend returns 500 | Check `docker compose logs backend` | Level 1 (Check logs) |
| Docker container won't start | `docker compose logs [service]`, check Dockerfile | Level 1 |
| Git merge conflict | Check conflicting files, resolve manually, test | Level 2 |
| Database corruption | Restore from backup OR recreate (lose test data) | Level 2 |
| API endpoint crashes consistently | Review code in `backend/app.py`, trace error | Level 2 |
| Challenge container SSH fails | Verify Dockerfile SSH config, test manually | Level 2 |
| Unclear if safe to proceed | Ask for explicit approval (message) | Level 3 (Human) |

**Debug Command Sequence:**
```bash
# Step 1: Check all services
docker compose ps

# Step 2: View backend logs
docker compose logs backend --tail=50

# Step 3: Test endpoint manually
curl -s http://localhost:5000/api/health | jq .

# Step 4: Check git state
git status && git diff --stat

# Step 5: Restart if needed
docker compose down && docker compose up -d && sleep 5
```

---

## CHANGE PROPOSAL TEMPLATE

**For any change affecting >2 files or >50 lines:**

```markdown
## Change Proposal: [Clear Title]

**Problem:**
Describe what's broken or what needs improvement.

**Proposed Solution:**
- File 1: [What changes]
- File 2: [What changes]
- [Any config/infra changes]

**Impact:**
- Breaking changes: [Yes/No, explain]
- Database migrations: [Yes/No]
- Requires restart: [Yes/No, which services]
- Backwards compatible: [Yes/No]

**Testing Plan:**
1. Run: [specific command]
2. Verify: [expected result]
3. Rollback plan: [if it fails, how to revert]

**Estimated Risk:** [Low/Medium/High]
```

---

## GIT PRACTICES

### Branch Strategy
- **main**: Production, always stable, only commits with verified tests
- **feature/***: Feature branches (not used in current solo dev, but standard)
- No `git rebase` on main; use `git merge` only

### Commit Frequency
- Small changes (bug fixes): 1 commit per fix
- Features: 1–3 commits (logical grouping)
- Avoid: "WIP", "temp", "debug" commits on main

### Push Protocol
```bash
# Before pushing, ensure:
git log --oneline origin/main..main  # See what's new locally
git diff origin/main -- backend/     # Review backend changes
git push origin main                 # Only after review
```

---

## TESTING CADENCE

**After each commit, run:**

1. **Smoke Test (2 min)**
   ```bash
   curl -s http://localhost:5000/api/health | jq .
   ```

2. **API Health Check (3 min)**
   ```bash
   cd ~/Documents/cyberforge && \
   echo "Challenges:" && curl -s http://localhost:5000/api/challenges | jq '.[] | .id' && \
   echo "Leaderboard:" && curl -s -H "Authorization: Bearer $(curl -s -X POST http://localhost:5000/api/login -H "Content-Type: application/json" -d '{"username":"user2","password":"Pass123"}' | jq -r '.access_token')" http://localhost:5000/api/leaderboard | jq 'length'
   ```

3. **SSH Spot Check (2 min, ch1 only)**
   ```bash
   ssh -p 2222 ctfuser@localhost
   # Inside: cat ~/challenge/flag.txt
   exit
   ```

---

## ROLLBACK PROCEDURES

**If a commit breaks production:**

```bash
# Option 1: Revert last commit (creates new commit)
git revert HEAD --no-edit && git push origin main

# Option 2: Soft reset (undo locally, re-commit with fix)
git reset --soft HEAD~1 && git status

# Option 3: Hard reset to known-good state (DANGER: loses changes)
git reset --hard origin/main~1 && git push --force-with-lease origin main
```

**Recovery Priority:**
1. Restore backend health
2. Verify databases intact
3. Re-run smoke tests
4. Communicate status

---

## WEEKLY CHECKLIST

Every 5–7 days:

- [ ] `git log --oneline main` shows reasonable commit history (no spam)
- [ ] All test users still have correct points (verify in `/api/leaderboard`)
- [ ] SSH ch1–ch3 manually tested at least once
- [ ] Database size reasonable (`ls -lh backend/cyberforge.db`)
- [ ] Docker images up-to-date (`docker images`)
- [ ] No stale branches cluttering repo

**Maintenance Command:**
```bash
cd ~/Documents/cyberforge && \
echo "=== GIT HEALTH ===" && git log --oneline -5 && \
echo -e "\n=== DOCKER HEALTH ===" && docker compose ps && \
echo -e "\n=== DB SIZE ===" && ls -lh backend/cyberforge.db && \
echo -e "\n=== LEADERBOARD STATE ===" && curl -s -H "Authorization: Bearer $(curl -s -X POST http://localhost:5000/api/login -H "Content-Type: application/json" -d '{"username":"user2","password":"Pass123"}' | jq -r '.access_token')" http://localhost:5000/api/leaderboard | jq .
```

---

## PROHIBITED ACTIONS

❌ **Never:**
- Commit to main with failing tests
- Use `git rebase` on main
- Modify SSH challenge Dockerfiles without explicit approval
- Push unreviewed database migrations
- Leave debug prints in production code
- Expose credentials in git history
- Force-push to main (use `--force-with-lease` only in emergency)
- Run commands as root unnecessarily
- Skip the pre-change checklist

---

## APPROVED TEST ACCOUNTS

| Username | Password | Purpose | Points | Created |
|----------|----------|---------|--------|---------|
| user2 | Pass123 | Main test user | 100 (ch1) | 2025-11-29 |
| apitest | Pass123 | API integration tests | 100 (ch1) | 2025-11-29 |
| testadmin | Pass123 | Admin testing | 0 | 2025-11-29 |
| admin | Pass123 | Production admin | 0 | Initial |

---

## CONTACT & ESCALATION

If stuck or unsure:
1. Check `/logs` or `docker compose logs [service]`
2. Review CYBERFORGE_KNOWLEDGE_BASE_v4.md for similar issues
3. Ask for explicit confirmation before risky operations
