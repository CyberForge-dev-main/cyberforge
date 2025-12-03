# CyberForge Knowledge Base v4.0

**Last Updated:** 2025-11-29 | **Status:** Production-Verified

---

## Architecture Overview

### Tech Stack
- **Backend:** Flask 2.3+ (Python 3.9+) on port 5000
- **Database:** SQLite (`cyberforge.db`) with SQLAlchemy ORM
- **Auth:** JWT (PyJWT) with 1-hour expiry
- **Frontend:** Nginx serving static HTML on port 3000
- **Challenges:** Docker containers (ch1: 2222, ch2: 2223, ch3: 2224)
- **DevOps:** Docker Compose v3.8+ for orchestration

### Repository
- **URL:** https://github.com/CyberForge-dev-main/cyberforge
- **Branch:** main (production)
- **Last Verified Commit:** `8702241` - "fix: backend auth and leaderboard flow"

---

## Database Schema (Current)

### Users Table
```
id (PK, Integer) | username (String, Unique) | email (String) | password_hash (String) | created_at (DateTime)
```

### Challenges Table
```
id (PK) | name | description | points | port | difficulty | category
Values: 
  1 | Challenge 1 | First SSH challenge | 100 | 2222 | Easy | SSH
  2 | Challenge 2 | Second SSH challenge | 100 | 2223 | Easy | SSH
  3 | Challenge 3 | Third SSH challenge | 100 | 2224 | Medium | SSH
```

### Submissions Table
```
id (PK) | user_id (FK) | challenge_id (FK) | flag | is_correct | submitted_at | points_awarded
```

---

## SSH Challenges - VERIFIED CREDENTIALS

### Challenge 1 (ch1) ✓ TESTED
- **Port:** 2222
- **Container:** cyberforge-ch1
- **Username:** `ctfuser`
- **Password:** `password123`
- **Flag:** `flag{welcome_to_cyberforge_1}`
- **Flag Location:** `/home/ctfuser/challenge/flag.txt`
- **Test Status:** ✓ Manual SSH login and flag retrieval confirmed (2025-11-29 18:42 UTC)

### Challenge 2 (ch2) ⏳ NOT YET TESTED
- **Port:** 2223
- **Container:** cyberforge-ch2
- **Username:** `ctfuser` (assumed, verify in Dockerfile)
- **Password:** `password123` (assumed, verify in Dockerfile)
- **Flag:** `flag{welcome_to_cyberforge_2}` (assumed)

### Challenge 3 (ch3) ⏳ NOT YET TESTED
- **Port:** 2224
- **Container:** cyberforge-ch3
- **Username:** `ctfuser` (assumed, verify in Dockerfile)
- **Password:** `password123` (assumed, verify in Dockerfile)
- **Flag:** `flag{welcome_to_cyberforge_3}` (assumed)

---

## API Endpoints - VERIFIED & TESTED

### Authentication Endpoints

**POST /api/register**
```
Request: {"username": "user", "email": "user@host.local", "password": "Pass123"}
Response: 201 {"message": "User registered successfully", "user": {...}}
Status: ✓ TESTED (apitest user created)
```

**POST /api/login**
```
Request: {"username": "user", "password": "Pass123"}
Response: 200 {"access_token": "JWT...", "message": "Login successful", "user": {...}}
Status: ✓ TESTED (JWT generation verified)
JWT Format: {"sub": "5", "iat": 1234567890, ...}
Token Validation: Must use int(identity) in code
```

### Challenge Endpoints

**GET /api/challenges**
```
Response: 200 [
  {"id": 1, "name": "Challenge 1", "description": "First SSH...", "points": 100, "port": 2222},
  {"id": 2, "name": "Challenge 2", ...},
  {"id": 3, "name": "Challenge 3", ...}
]
Status: ✓ TESTED (3 challenges returned with correct ports)
```

**GET /api/health**
```
Response: 200 {"message": "Backend is running", "status": "OK"}
Status: ✓ TESTED (always returns 200)
```

### Scoring Endpoints

**POST /api/submit_flag**
```
Request: {"challenge_id": 1, "flag": "flag{welcome_to_cyberforge_1}"}
Headers: Authorization: Bearer [JWT_TOKEN]
Response (Success): 200 {"message": "Correct flag!", "points": 100, "success": true}
Response (Failure): 400 {"message": "Incorrect flag", "success": false}
Status: ✓ TESTED (both scenarios verified)
Business Logic:
  - On success: Create Submission record with is_correct=true
  - Prevent duplicate scoring: Check if (user, challenge) pair already submitted correctly
  - Return points value from Challenge.points
Note: Leaderboard update is automatic (see GET /api/leaderboard)
```

**GET /api/leaderboard**
```
Headers: Authorization: Bearer [JWT_TOKEN]
Response: 200 [
  {"username": "user2", "points": 100, "solved": 1},
  {"username": "apitest", "points": 100, "solved": 1},
  {"username": "testadmin", "points": 0, "solved": 0}
]
Status: ✓ TESTED (sorting by points DESC, no ORM errors)
Algorithm (Fixed in v4):
  1. Get all users: User.query.all()
  2. For each user, count correct Submissions: Submission.query.filter_by(user_id=X, is_correct=True).all()
  3. For each correct submission, sum Challenge.points
  4. Sort by total_points DESC, then username ASC
```

**GET /api/user/progress**
```
Headers: Authorization: Bearer [JWT_TOKEN]
Response: 200 {"challenges_solved": 1, "total_points": 100, "username": "user2"}
Status: ✓ TESTED (correct aggregation for test users)
```

---

## Known Issues & Fixes

### Issue 1: JWT Identity Type Mismatch (FIXED in v4)
**Problem:** `get_jwt_identity()` returns string, but code expects int
**Symptom:** "TypeError: unsupported operand type(s)" when querying user
**Solution:** Wrap with `int()`: `user_id = int(get_jwt_identity())`
**File:** `backend/auth.py` (updated)
**Status:** ✓ RESOLVED

### Issue 2: Leaderboard ORM Join Errors (FIXED in v4)
**Problem:** Complex SQLAlchemy JOIN would fail with "join() got multiple values for keyword argument"
**Symptom:** `GET /api/leaderboard` returns 500 error
**Solution:** Replaced with Python-level aggregation (simple loop + sum)
**File:** `backend/app.py` (rewritten)
**Status:** ✓ RESOLVED

### Issue 3: Outdated SSH Credentials in Documentation
**Problem:** Knowledge Base listed generic credentials (`cyber/cyberforge`)
**Symptom:** SSH login fails with "Permission denied"
**Solution:** Updated all SSH creds to verified `ctfuser/password123`
**Files:** CYBERFORGE_KNOWLEDGE_BASE_v4.md, tested manually
**Status:** ✓ RESOLVED

---

## Common Operations

### Reset Database
```bash
cd ~/Documents/cyberforge && \
rm backend/cyberforge.db && \
docker compose up -d && \
sleep 5 && \
# Re-seed with test users if needed
curl -X POST http://localhost:5000/api/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@test.local","password":"Pass123"}'
```

### View Backend Logs
```bash
docker compose logs backend -f --tail=50
```

### SSH into Challenge Container
```bash
docker exec -it cyberforge-ch1 /bin/bash
# Inside: cat /home/ctfuser/challenge/flag.txt
```

### Rebuild Containers
```bash
docker compose down && \
docker compose build && \
docker compose up -d
```

---

## Testing Checklist

- [x] Health endpoint responds with 200
- [x] Challenges endpoint returns 3 items
- [x] User registration works
- [x] User login returns JWT
- [x] Submit correct flag: success=true, points=100
- [x] Submit incorrect flag: success=false
- [x] Leaderboard returns users sorted by points
- [x] User progress aggregates correctly
- [x] SSH ch1 login with ctfuser/password123 works
- [x] SSH ch1 flag file is readable
- [ ] ch2 SSH credentials verified (pending)
- [ ] ch3 SSH credentials verified (pending)
- [ ] API rate limiting (not implemented)
- [ ] JWT expiry handling (not implemented)

---

## TODO (Next Sprint)
- [ ] Verify SSH credentials for ch2, ch3
- [ ] Add rate limiting to /api/submit_flag
- [ ] Implement JWT refresh token flow
- [ ] Add user roles (admin, participant, observer)
- [ ] Add submission history endpoint
- [ ] Frontend UI for leaderboard
