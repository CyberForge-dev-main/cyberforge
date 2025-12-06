# CyberForge

Self-hosted cybersecurity training platform with isolated sandbox environments and automated flag validation.

## Overview

CyberForge provides a containerized infrastructure for hands-on cybersecurity practice. Features include:

- **6 Built-in Challenges**: 3 SSH-based Linux challenges + 3 Web security challenges (OWASP Juice Shop integration)
- **Real-time Scoring**: Automated flag validation with leaderboard
- **Container Isolation**: Each challenge runs in isolated Docker environment
- **Rate Limiting**: Anti-brute-force protection (5 attempts per 60 seconds)
- **Category System**: SSH, Web, Crypto, Forensics support
- **Difficulty Levels**: Easy, Medium, Hard badges

## Quick Start

### Prerequisites

- Docker and Docker Compose
- Ports: 3000 (web), 5000 (API), 2222-2224 (SSH), 3001 (Juice Shop)
- 4GB RAM minimum

### Installation

```bash
git clone https://github.com/CyberForge-dev-main/cyberforge.git
cd cyberforge
docker compose up -d
```

Wait 30 seconds, then access:
- **Web Interface**: http://localhost:3000
- **API Health**: http://localhost:5000/api/health
- **Juice Shop**: http://localhost:3001

### First Steps

1. Register account at http://localhost:3000
2. SSH to challenge: `ssh ctfuser@localhost -p 2222` (password: `password123`)
3. Find flag and submit on web interface
4. Check leaderboard!

## Project Structure
## Available Commands

```bash
make up          # Start all containers
make down        # Stop and remove containers
make restart     # Restart all services
make logs        # Follow container logs
make ps          # Show container status
make test        # Run integration tests
make health      # System health check
```

## Challenges

### SSH Challenges

| ID | Name | Difficulty | Points | Port | Flag |
|----|------|------------|--------|------|------|
| 1 | SSH Basics | Easy | 100 | 2222 | `flag{welcome_to_cyberforge_1}` |
| 2 | Hidden Files | Easy | 100 | 2223 | `flag{linux_basics_are_fun}` |
| 3 | Directory Search | Medium | 100 | 2224 | `flag{find_and_conquer}` |

**Credentials**: `ctfuser` / `password123`

### Web Challenges (OWASP Juice Shop)

| ID | Name | Difficulty | Points | Description |
|----|------|------------|--------|-------------|
| 4 | Admin Login | Easy | 150 | Login as admin |
| 5 | SQL Injection | Medium | 200 | Bypass authentication |
| 6 | XSS Attack | Medium | 200 | Execute XSS payload |

Access Juice Shop at http://localhost:3001

## API Endpoints

### Public Endpoints
- `GET /api/health` - Health check
- `POST /api/register` - User registration
- `POST /api/login` - User authentication
- `GET /api/challenges` - List all challenges

### Protected Endpoints (require JWT)
- `POST /api/submit_flag` - Submit flag for validation
- `GET /api/leaderboard` - Get leaderboard
- `GET /api/user/progress` - Get user progress

## Development

### Backend Development

```bash
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python app.py
```

### Frontend Development

```bash
cd website
python3 -m http.server 3000
```

## Database Schema

### Users Table
- id (Primary Key)
- username (Unique)
- email (Unique)
- password_hash
- created_at

### Challenges Table
- id (Primary Key)
- name
- description
- flag
- points
- port
- category (SSH, Web, Crypto, Forensics)
- difficulty (Easy, Medium, Hard)

### Submissions Table
- id (Primary Key)
- user_id (Foreign Key)
- challenge_id (Foreign Key)
- submitted_flag
- is_correct
- submitted_at

## Security Features

- **JWT Authentication**: Secure token-based auth with 24h expiration
- **Rate Limiting**: 5 flag submission attempts per 60 seconds
- **Password Hashing**: SHA-256 hashed passwords
- **Container Isolation**: Challenges run in separate containers
- **No Root SSH**: SSH challenges run as unprivileged user

## Troubleshooting

### Containers won't start
```bash
docker compose down
docker compose up -d --build
```

### Backend not responding
```bash
docker compose logs backend
docker compose restart backend
```

### Port conflicts
```bash
# Check ports
sudo netstat -tulpn | grep -E ':(3000|5000|2222|2223|2224|3001)'

# Change ports in docker-compose.yml
```

## Contributing

1. Fork repository
2. Create feature branch (`git checkout -b feature/new-challenge`)
3. Commit changes (`git commit -m 'Add new challenge'`)
4. Push to branch (`git push origin feature/new-challenge`)
5. Open Pull Request

## License

MIT License - see LICENSE file

## Roadmap

- [ ] More challenge categories (Crypto, Forensics, Reverse Engineering)
- [ ] Team support and CTF events
- [ ] Hints system
- [ ] Challenge timer
- [ ] Admin dashboard
- [ ] HTTPS/SSL support
- [ ] Production deployment guide
