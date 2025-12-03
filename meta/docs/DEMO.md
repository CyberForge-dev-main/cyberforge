# 🎯 CyberForge Demo Guide

**Quick demonstration guide for showcasing CyberForge capabilities.**

---

## 📊 Problem & Solution

### Problem
- Cybersecurity students need **hands-on practice** but lack safe environments
- Existing platforms (HackTheBox, TryHackMe) require **subscription** and **online access**
- Educational institutions need **self-hosted** solutions for **classroom training**
- Team CTF training requires **isolated, reproducible environments**

### Solution: CyberForge
- **Self-hosted** platform running entirely on Docker
- **3 SSH challenges** + **OWASP Juice Shop** for web vulnerabilities
- **Backend API** for progress tracking and leaderboards
- **Free and open-source** — perfect for schools, bootcamps, CTF teams

---

## 🚀 Quick Start Demo

### 1. Setup (45 seconds)

```bash
git clone https://github.com/CyberForge-dev-main/cyberforge.git
cd cyberforge
chmod +x setup.sh
./setup.sh
```

The script will:
- Check Docker installation
- Start all services (6 containers)
- Run health checks
- Display access points

### 2. Access Points

| Service | URL/Command | Purpose |
|---------|-------------|----------|
| 🎨 Dashboard | http://localhost:3000 | Main interface |
| 🔌 Backend API | http://localhost:5000/api | REST API for challenges |
| 🍊 Juice Shop | http://localhost:3001 | Web vulnerability practice |
| 💻 SSH Challenge 1 | `ssh ctfuser@localhost -p 2222` | Basic reconnaissance |
| 💻 SSH Challenge 2 | `ssh ctfuser@localhost -p 2223` | File permissions |
| 💻 SSH Challenge 3 | `ssh ctfuser@localhost -p 2224` | Privilege escalation |

---

## 🎮 Demo Scenarios

### Scenario 1: SSH Challenge Walkthrough

**Challenge 1: Find the Flag**

```bash
# Connect to challenge 1
ssh ctfuser@localhost -p 2222
# Password: password123

# Search for flag
find / -name "flag.txt" 2>/dev/null
cat /home/ctfuser/challenge/flag.txt

# Result: flag{welcome_to_cyberforge_1}
```

**Challenge 2: Hidden Files**

```bash
ssh ctfuser@localhost -p 2223
# Password: password123

# List hidden files
ls -la ~
cat ~/.hidden_flag

# Result: flag{linux_basics_are_fun}
```

**Challenge 3: Explore Directories**

```bash
ssh ctfuser@localhost -p 2224
# Password: password123

# Search in unusual locations
find ~ -name "*.txt" 2>/dev/null
cat ~/secret_dir/flag3.txt

# Result: flag{find_and_conquer}
```

### Scenario 2: API Usage

**Register User**

```bash
curl -X POST http://localhost:5000/api/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "demo_user",
    "email": "demo@cyberforge.dev",
    "password": "SecurePass123!"
  }'
```

**Login**

```bash
curl -X POST http://localhost:5000/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "demo_user",
    "password": "SecurePass123!"
  }'

# Save the access_token from response
```

**Submit Flag**

```bash
curl -X POST http://localhost:5000/api/submit_flag \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "challenge_id": 1,
    "flag": "flag{welcome_to_cyberforge_1}"
  }'
```

**Check Leaderboard**

```bash
curl http://localhost:5000/api/leaderboard
```

### Scenario 3: Juice Shop (Web Vulnerabilities)

1. Open http://localhost:3001
2. Try SQL injection on login: `' OR 1=1--`
3. Explore XSS vulnerabilities in search
4. Discover hidden admin panel
5. Practice 100+ OWASP challenges

---

## 📊 Key Metrics

**Performance:**
- Startup time: ~45 seconds
- 6 containers running simultaneously
- Low resource usage (~2GB RAM, minimal CPU)

**Challenge Coverage:**
- 3 SSH challenges (Easy difficulty)
- 100+ web challenges (Juice Shop)
- API-driven progress tracking

---

## 🎯 Competitive Advantages

| Feature | CyberForge | HackTheBox | TryHackMe |
|---------|-----------|------------|------------|
| **Self-hosted** | ✅ Yes | ❌ No | ❌ No |
| **Free** | ✅ 100% | 🟡 Limited | 🟡 Limited |
| **Offline mode** | ✅ Yes | ❌ No | ❌ No |
| **Classroom ready** | ✅ Yes | ❌ No | 🟡 Enterprise only |
| **Open source** | ✅ Yes | ❌ No | ❌ No |
| **Customizable** | ✅ Yes | ❌ No | ❌ No |

---

## 🛠️ Technical Architecture

```
┌─────────────────────────────────────────────┐
│         Docker Compose Network            │
├─────────────────────────────────────────────┤
│                                           │
│  Frontend   Backend    Juice Shop          │
│  (React)    (Flask)    (Node.js)           │
│  :3000      :5000      :3001               │
│                                           │
│  SSH-1      SSH-2      SSH-3               │
│  :2222      :2223      :2224               │
│                                           │
└─────────────────────────────────────────────┘
```

**Tech Stack:**
- **Backend:** Python 3.11, Flask, SQLAlchemy, JWT
- **Frontend:** React 18, Axios
- **Infrastructure:** Docker, Docker Compose, Alpine Linux
- **Challenges:** Ubuntu-based SSH containers, OWASP Juice Shop

---

## 🔧 Maintenance & Monitoring

**Health Check:**

```bash
./check_health.sh
```

**View Logs:**

```bash
docker compose logs -f backend
docker compose logs -f website
```

**Restart Services:**

```bash
docker compose restart backend
```

**Stop Everything:**

```bash
docker compose down
```

---

## 🚀 Roadmap

### ✅ Phase 1-4: Complete
- [x] 3 SSH challenges
- [x] Backend REST API
- [x] Juice Shop integration
- [x] Health checks & automation

### 🚧 Phase 5: In Progress
- [ ] User authentication UI
- [ ] Progress dashboard
- [ ] Real-time leaderboard
- [ ] Challenge completion tracking

### 📋 Phase 6: Planned
- [ ] Additional challenge types (forensics, crypto)
- [ ] Team competition mode
- [ ] Instructor admin panel
- [ ] Challenge creator toolkit

---

## 💬 Talking Points for Presentation

1. **Problem**: Cybersecurity education lacks accessible, hands-on practice environments
2. **Market**: $3.2B cybersecurity training market, 3.5M unfilled jobs globally
3. **Solution**: Self-hosted, free platform anyone can run
4. **Differentiation**: Only fully open-source, classroom-ready CTF platform
5. **Traction**: Working MVP, Docker-based, production-ready
6. **Business Model**: Open-source core + enterprise features (SSO, analytics, custom challenges)

---

## 👥 Target Users

- **Students**: Free practice environment for learning
- **Bootcamps**: Ready-made curriculum for cybersecurity courses
- **CTF Teams**: Local training environment for competitions
- **Corporations**: Internal security training without cloud dependencies
- **Universities**: Self-hosted lab environment for courses

---

## 📝 Quick Demo Script (5 minutes)

1. **[0:00-0:30]** Show `./setup.sh` running
2. **[0:30-1:00]** Open dashboard at http://localhost:3000
3. **[1:00-2:00]** SSH into Challenge 1, find flag
4. **[2:00-3:00]** Show Juice Shop vulnerabilities
5. **[3:00-4:00]** Demonstrate API (register, login, submit flag)
6. **[4:00-5:00]** Show leaderboard & health check

---

**Ready to deploy? Run `./setup.sh` and start practicing!** 🚀
