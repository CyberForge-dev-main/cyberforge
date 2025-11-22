# CyberForge - Interactive Cybersecurity Training Platform

An all-in-one platform for learning cybersecurity through hands-on challenges: SSH exploitation, web vulnerabilities, and API security.

---

## Quick Start (5 minutes)

### Requirements
- Docker & Docker Compose installed
- 1GB free disk space
- Linux/macOS (or WSL on Windows)

### 1. Clone Repository
```
git clone https://github.com/CyberForge-dev-main/cyberforge.git
cd cyberforge
```

### 2. Start All Services
```
docker compose up -d
sleep 45
```

### 3. Access Services

| Service | URL | Purpose |
|---------|-----|---------|
| Dashboard | http://localhost:3000 | Main interface |
| Juice Shop | http://localhost:3001 | Web vulnerabilities |
| Backend API | http://localhost:5000/api | Challenge management |

### 4. SSH Challenges
```
# Challenge 1 (port 2222)
ssh ctfuser@localhost -p 2222
# Password: password123

# Challenge 2 (port 2223)
ssh ctfuser@localhost -p 2223

# Challenge 3 (port 2224)
ssh ctfuser@localhost -p 2224
```

---

## What is Included

### Phase 1: SSH Challenges
- 3 progressive Linux challenges
- Flag finding & command execution
- Ports: 2222, 2223, 2224

### Phase 2: Backend API
- Flask REST API
- SQLite database
- JWT authentication ready

### Phase 3: OWASP Juice Shop
- Web vulnerability training
- SQL injection, XSS, brute force
- Real-world scenarios

### Phase 4: Testing
- Health check script
- Full test coverage
- All systems validated

---

## Tech Stack

Backend: Python 3.11 + Flask
Frontend: React 18 + Nginx
Vulnerabilities: OWASP Juice Shop
Orchestration: Docker Compose
Database: SQLite

---

## Commands

### Check Status
```
docker compose ps
./tests/health_check.sh
```

### View Logs
```
docker compose logs -f website
docker compose logs -f backend
docker compose logs -f juice-shop
```

### Stop Services
```
docker compose down
```

### Clean Everything
```
docker compose down -v
docker system prune -f --volumes
```

---

## How It Works

1. Dashboard (port 3000) - See all available challenges

2. SSH Challenges - Connect and find flags:
```
ssh ctfuser@localhost -p 2222
$ find / -name "flag.txt" 2>/dev/null
$ cat /root/flag.txt
```

3. Juice Shop (port 3001) - Exploit web vulnerabilities:
   - Admin panel bypass
   - SQL injection
   - XSS attacks
   - Brute force

4. Backend API (port 5000) - Programmatic access to challenge data

---

## Testing

Run health checks:
```
./tests/health_check.sh
```

Review test checklist:
```
cat TESTING_CHECKLIST.md
```

---

## Project Structure

cyberforge/
├── docker-compose.yml
├── README.md
├── TESTING_CHECKLIST.md
├── backend/
│   ├── app.py
│   ├── models.py
│   └── Dockerfile
├── website/
│   └── Dockerfile
├── challenges/
│   ├── ch1/Dockerfile
│   ├── ch2/Dockerfile
│   └── ch3/Dockerfile
└── tests/
    └── health_check.sh

---

## Network Access (WiFi Demo)

Share internet from this machine:
1. Enable WiFi hotspot: CyberForge-Demo
2. Other devices connect to WiFi
3. Access services via your machine IP (e.g., 192.168.0.114)

```
# Get your IP
hostname -I

# Access from another device
ssh ctfuser@192.168.0.114 -p 2222
open http://192.168.0.114:3000
```

---

## Troubleshooting

Port already in use?
```
docker compose down
docker system prune -f --volumes
```

Container won't start?
```
docker compose logs backend
docker compose logs juice-shop
```

SSH connection refused?
```
# Wait 30 seconds for SSH to boot
sleep 30
ssh ctfuser@localhost -p 2222
```

---

## Next Steps

- Phase 1-4: Complete
- Phase 5: Full backend integration
- Phase 6: User accounts & leaderboard
- Phase 7: Mobile app

---

License

MIT License - Use freely for educational purposes.

---

Questions? Open an issue on GitHub.

