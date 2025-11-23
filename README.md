<![CDATA[<div align="center">

# 🛡️ CyberForge

### Interactive Cybersecurity Training Platform

*Master cybersecurity through hands-on challenges: SSH exploitation, web vulnerabilities, and API security*

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](docker-compose.yml)
[![Python](https://img.shields.io/badge/Python-3.11-green.svg)](backend/)
[![React](https://img.shields.io/badge/React-18-blue.svg)](package.json)

[Quick Start](#-quick-start) • [Features](#-features) • [Architecture](#️-architecture) • [Documentation](#-documentation)

</div>

---

## 🎯 Overview

CyberForge is an all-in-one platform for learning cybersecurity through real-world scenarios. It combines Docker-isolated challenges with a modern web interface to provide a safe, comprehensive training environment.

### What Makes CyberForge Unique?

- **🚀 5-minute setup** with Docker Compose
- **🔒 Isolated environments** for safe exploitation practice
- **📊 Progress tracking** with backend API
- **🎓 Progressive difficulty** from beginner to advanced
- **💻 Multi-platform** support (Linux, macOS, WSL)

---

## ⚡ Quick Start

### Prerequisites

```bash
# Check Docker installation
docker --version && docker compose version

# Requirements:
# - Docker & Docker Compose
# - 1GB free disk space
# - Linux/macOS (or WSL on Windows)
```

### Installation

```bash
# 1. Clone repository
git clone https://github.com/CyberForge-dev-main/cyberforge.git
cd cyberforge

# 2. Start all services
docker compose up -d

# 3. Wait for initialization (45 seconds)
sleep 45

# 4. Verify health
./tests/health_check.sh
```

### Access Points

| Service | URL | Credentials |
|---------|-----|-------------|
| 🎨 Dashboard | `http://localhost:3000` | No auth required |
| 🍊 Juice Shop | `http://localhost:3001` | Create account |
| 🔌 Backend API | `http://localhost:5000/api` | JWT-based |
| 🖥️ SSH Challenge 1 | `ssh ctfuser@localhost -p 2222` | `password123` |
| 🖥️ SSH Challenge 2 | `ssh ctfuser@localhost -p 2223` | *Find password* |
| 🖥️ SSH Challenge 3 | `ssh ctfuser@localhost -p 2224` | *Escalate privileges* |

---

## 🎓 Features

### 🐧 SSH Challenges

Three progressive Linux challenges teaching:
- Command-line navigation
- File permissions & privilege escalation
- Flag hunting techniques
- Basic exploitation

**Example:**
```bash
ssh ctfuser@localhost -p 2222
$ find / -name "flag.txt" 2>/dev/null
$ cat /root/flag.txt
FLAG{your_first_flag}
```

### 🌐 Web Vulnerabilities (OWASP Juice Shop)

Real-world web application with 100+ challenges:
- 🔑 Authentication bypass
- 💉 SQL injection
- 🔓 XSS attacks
- 🔐 Broken access control
- 🛒 Business logic flaws

### 🔌 REST API Backend

Flask-based API for challenge management:
- Challenge CRUD operations
- User progress tracking
- JWT authentication (ready for Phase 5)
- SQLite database

**Example API calls:**
```bash
# Get all challenges
curl http://localhost:5000/api/challenges

# Submit flag
curl -X POST http://localhost:5000/api/challenges/1/submit \
  -H "Content-Type: application/json" \
  -d '{"flag": "FLAG{...}"}'
```

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Docker Compose Network                   │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Website    │  │   Backend    │  │  Juice Shop  │      │
│  │  (React 18)  │  │ (Flask/API)  │  │   (Node.js)  │      │
│  │   Port 3000  │  │   Port 5000  │  │   Port 3001  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Challenge 1 │  │  Challenge 2 │  │  Challenge 3 │      │
│  │   (Alpine)   │  │   (Alpine)   │  │   (Alpine)   │      │
│  │   Port 2222  │  │   Port 2223  │  │   Port 2224  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### Tech Stack

**Frontend:**
- React 18.2
- Axios for API calls
- Nginx for production serving

**Backend:**
- Python 3.11
- Flask REST framework
- SQLite database
- JWT authentication ready

**Infrastructure:**
- Docker & Docker Compose
- Alpine Linux containers
- OpenSSH Server
- Multi-stage builds

---

## 📁 Project Structure

```
cyberforge/
├── 📄 docker-compose.yml          # Orchestration config
├── 📄 README.md                   # This file
├── 📄 LICENSE                     # MIT License
├── 📄 TESTING_CHECKLIST.md        # QA checklist
├── 📄 package.json                # Frontend dependencies
│
├── 🐳 Dockerfile.ch1              # Challenge 1 container
├── 🐳 Dockerfile.ch2              # Challenge 2 container
├── 🐳 Dockerfile.ch3              # Challenge 3 container
│
├── 🔧 backend/                    # Flask REST API
│   ├── app.py                     # Main application
│   ├── models.py                  # Database models
│   ├── auth.py                    # JWT authentication
│   ├── config.py                  # Configuration
│   ├── requirements.txt           # Python dependencies
│   └── Dockerfile                 # Backend container
│
├── 🎨 src/                        # React frontend
│   ├── App.js                     # Main component
│   ├── api.js                     # API client
│   └── components/                # UI components
│
├── 🌐 website/                    # Website deployment
│   └── Dockerfile                 # Frontend container
│
├── 🧪 tests/                      # Testing suite
│   └── health_check.sh            # Automated health checks
│
└── 📜 scripts/                    # Utility scripts
    └── ...
```

---

## 🔧 Commands

### Managing Services

```bash
# Start all services
docker compose up -d

# View status
docker compose ps

# View logs
docker compose logs -f website
docker compose logs -f backend
docker compose logs -f juice-shop

# Stop services
docker compose down

# Restart single service
docker compose restart backend

# Rebuild after changes
docker compose up -d --build
```

### Testing

```bash
# Run health checks
./tests/health_check.sh

# Check individual service
curl http://localhost:5000/api/health

# SSH connection test
ssh -o ConnectTimeout=5 ctfuser@localhost -p 2222
```

### Cleanup

```bash
# Remove containers and volumes
docker compose down -v

# Full system cleanup
docker system prune -f --volumes
```

---

## 🌐 Network Sharing (Demo Mode)

Share CyberForge over WiFi for classroom/demo scenarios:

```bash
# 1. Find your IP address
hostname -I  # Linux
ifconfig | grep inet  # macOS

# 2. Enable WiFi hotspot (optional)
# Hotspot name: CyberForge-Demo

# 3. Access from other devices
# Replace 192.168.0.114 with your IP
ssh ctfuser@192.168.0.114 -p 2222
# Open http://192.168.0.114:3000 in browser
```

---

## 📚 Documentation

### Challenge Walkthroughs

**Challenge 1: Basic Reconnaissance**
```bash
ssh ctfuser@localhost -p 2222
# Password: password123

# Find the flag
find / -name "flag.txt" 2>/dev/null
cat /root/flag.txt
```

**Challenge 2: Password Cracking**
```bash
ssh ctfuser@localhost -p 2223

# Find weak credentials
cat /etc/passwd
# Crack or guess password
```

**Challenge 3: Privilege Escalation**
```bash
ssh ctfuser@localhost -p 2224

# Find SUID binaries
find / -perm -4000 2>/dev/null

# Exploit misconfigured permissions
```

### API Documentation

**Base URL:** `http://localhost:5000/api`

**Endpoints:**
```
GET    /api/health              # Health check
GET    /api/challenges          # List all challenges
GET    /api/challenges/:id      # Get challenge details
POST   /api/challenges/:id/submit  # Submit flag
```

**Example Response:**
```json
{
  "challenges": [
    {
      "id": 1,
      "name": "SSH Challenge 1",
      "difficulty": "Easy",
      "points": 100,
      "description": "Find the flag in the system"
    }
  ]
}
```

---

## 🐛 Troubleshooting

### Port Already in Use

```bash
# Find process using port
sudo lsof -i :3000
sudo lsof -i :5000

# Kill process or change port in docker-compose.yml
docker compose down
docker compose up -d
```

### Container Won't Start

```bash
# Check logs
docker compose logs [service-name]

# Rebuild container
docker compose up -d --build [service-name]

# Reset everything
docker compose down -v
docker system prune -f --volumes
docker compose up -d
```

### SSH Connection Refused

```bash
# Wait for SSH to initialize (30-45 seconds)
sleep 45

# Check SSH service status
docker compose exec challenge1 ps aux | grep sshd

# Verify port mapping
docker compose ps
```

### Backend API Not Responding

```bash
# Check if backend is running
docker compose ps backend

# View backend logs
docker compose logs backend

# Restart backend
docker compose restart backend
```

---

## 🗺️ Roadmap

### ✅ Phase 1-4: Complete
- [x] SSH challenges (3 progressive levels)
- [x] Backend REST API
- [x] OWASP Juice Shop integration
- [x] Testing suite & health checks

### 🚧 Phase 5: Backend Integration (In Progress)
- [ ] User authentication system
- [ ] Progress tracking per user
- [ ] Flag validation logic
- [ ] Challenge completion stats

### 📋 Phase 6: Planned
- [ ] User dashboard with statistics
- [ ] Leaderboard system
- [ ] Hint system
- [ ] Admin panel

### 🔮 Phase 7: Future
- [ ] Mobile app (React Native)
- [ ] Additional challenge types
- [ ] Team competitions
- [ ] Custom challenge creator

---

## 🤝 Contributing

We welcome contributions! Here's how:

### Reporting Bugs

Open an issue with:
- Description of the bug
- Steps to reproduce
- Expected vs actual behavior
- Environment details (OS, Docker version)

### Adding Challenges

1. Fork the repository
2. Create new Dockerfile for challenge
3. Add entry to docker-compose.yml
4. Update README with challenge details
5. Submit pull request

### Code Contributions

```bash
# 1. Fork and clone
git clone https://github.com/YOUR_USERNAME/cyberforge.git

# 2. Create feature branch
git checkout -b feature/your-feature

# 3. Make changes and test
./tests/health_check.sh

# 4. Commit with clear message
git commit -m "Add: new challenge for XXX"

# 5. Push and create PR
git push origin feature/your-feature
```

**Commit Convention:**
- `Add:` new features
- `Fix:` bug fixes
- `Update:` improvements
- `Docs:` documentation changes

---

## 📝 License

MIT License - See [LICENSE](LICENSE) for details.

**Free for educational purposes.** Use responsibly.

---

## 🙏 Acknowledgments

- [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/) for web vulnerability training
- Docker community for containerization best practices
- React and Flask teams for excellent frameworks

---

## 📬 Contact

- **Issues:** [GitHub Issues](https://github.com/CyberForge-dev-main/cyberforge/issues)
- **Discussions:** [GitHub Discussions](https://github.com/CyberForge-dev-main/cyberforge/discussions)
- **Project:** [CyberForge on GitHub](https://github.com/CyberForge-dev-main/cyberforge)

---

<div align="center">

**⭐ Star this repo if you find it helpful!**

Made with 💙 for the cybersecurity community

</div>]]>