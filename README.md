
# CyberForge

Self-hosted cybersecurity training platform with isolated sandbox environments and automated flag validation.

## Overview

CyberForge provides a containerized infrastructure for hands-on cybersecurity practice. The platform includes multiple challenge types running in isolated Docker containers, an HTTP API for challenge management and scoring, and a web interface for user interaction.

### Key Characteristics

- **Self-hosted deployment** - Complete control over infrastructure and data
- **Container isolation** - Each challenge runs in its own Docker container with restricted permissions
- **Modular architecture** - Add or remove challenges independently
- **Local execution** - No external dependencies or cloud connectivity required
- **SQLite backend** - Lightweight persistence without additional database services

## Quick Start

### Prerequisites

- Docker and docker-compose installed
- Port availability: 3000, 5000, 2222-2224
- 4GB RAM minimum, 8GB recommended

### Installation

```bash
git clone https://github.com/CyberForge-dev-main/cyberforge.git
cd cyberforge
docker compose up --build -d
```

Deployment verification:

```bash
# Check container status
docker compose ps

# Verify API endpoint
curl http://localhost:5000/api/health

# Access web interface
http://localhost:3000
```

Wait 30 seconds for service initialization before accessing the interface.

## System Architecture

### Component Overview

The system consists of four primary components communicating through a Docker internal network:

```
┌─────────────────────────────────────────┐
│        User Browser                     │
│    (http://localhost:3000)              │
└────────────────┬────────────────────────┘
                 │
    ┌────────────┼────────────┐
    │            │            │
┌───▼────┐  ┌───▼─────┐  ┌──▼──────┐
│Frontend│  │ Backend │  │Challenges│
│:3000   │  │:5000    │  │:2222-2224│
└────────┘  └─────────┘  └──────────┘
                 │
           ┌─────▼─────┐
           │  SQLite   │
           │   DB      │
           └───────────┘
```

### Data Flow for Challenge Submission

1. User submits flag through web interface (HTTP POST to `/api/submit`)
2. Backend receives submission and queries challenge metadata from SQLite
3. Backend compares submitted flag with stored value
4. Result persisted to database (flag_submissions table)
5. User progress updated (points awarded if correct)
6. Response returned to frontend for display

### Port Mapping

| Component | Port | Protocol | Purpose |
|-----------|------|----------|---------|
| Frontend | 3000 | HTTP | Web interface |
| Backend API | 5000 | HTTP | REST endpoints |
| SSH Challenge 1 | 2222 | SSH | Interactive shell environment |
| SSH Challenge 2 | 2223 | SSH | Interactive shell environment |
| SSH Challenge 3 | 2224 | SSH | Interactive shell environment |

## Project Structure

```
cyberforge/
├── backend/                    # Flask API service
│   ├── app.py                 # Application entry point
│   ├── config.py              # Configuration settings (SQLite)
│   ├── models.py              # Database ORM models
│   ├── auth.py                # JWT authentication logic
│   ├── requirements.txt        # Python dependencies
│   └── Dockerfile             # Container image definition
│
├── website/                    # Frontend web interface
│   ├── index.html             # HTML markup
│   ├── app.js                 # React application
│   ├── components/            # React component modules
│   └── Dockerfile             # Container image definition
│
├── challenges/                 # SSH challenge environments
│   ├── ch1/Dockerfile         # Challenge 1 image
│   ├── ch2/Dockerfile         # Challenge 2 image
│   └── ch3/Dockerfile         # Challenge 3 image
│
├── tests/                      # Functional test suite
│   ├── test_api.sh            # API integration tests
│   └── test_ssh.sh            # SSH connection validation
│
├── docker-compose.yml         # Service orchestration
├── README.md                  # This file
└── .gitignore                 # Git exclusion rules
```

## API Reference

### Authentication

All requests except `/api/health` and `/api/register` require JWT token in Authorization header:

```
Authorization: Bearer <jwt_token>
```

### Endpoints

#### Health Check
```
GET /api/health
```
Returns service status.

#### User Registration
```
POST /api/register
Content-Type: application/json

{
  "username": "user1",
  "email": "user@example.com",
  "password": "secure_password"
}
```

#### User Login
```
POST /api/login
Content-Type: application/json

{
  "username": "user1",
  "password": "secure_password"
}
```
Returns JWT token for subsequent requests.

#### List Challenges
```
GET /api/challenges
Authorization: Bearer <token>
```
Returns array of available challenges with metadata.

#### Submit Flag
```
POST /api/submit
Authorization: Bearer <token>
Content-Type: application/json

{
  "challenge_id": 1,
  "flag": "flag{...}"
}
```
Returns validation result and points awarded.

#### Leaderboard
```
GET /api/leaderboard
Authorization: Bearer <token>
```
Returns ranked list of users by points.

## Challenge Environments

### SSH Challenge Access

```bash
ssh -p 2222 ctfuser@localhost          # Challenge 1
ssh -p 2223 ctfuser@localhost          # Challenge 2
ssh -p 2224 ctfuser@localhost          # Challenge 3

# Default credentials (if required)
# Password: ctfpass
```

### Challenge Structure

Each challenge container provides:
- Limited user account with restricted permissions
- Task description in `/home/ctfuser/README`
- Target objective requiring investigation and problem-solving
- Flag stored in hidden location

Example challenge flow:
1. Connect via SSH
2. Read task description
3. Investigate file system and process environment
4. Locate and extract flag
5. Submit flag through web interface

## Database Schema

### Users Table
```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Challenges Table
```sql
CREATE TABLE challenges (
    id INTEGER PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    flag VARCHAR(255) NOT NULL,
    points INTEGER DEFAULT 100,
    difficulty INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### User Progress Table
```sql
CREATE TABLE user_progress (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    challenge_id INTEGER NOT NULL,
    solved BOOLEAN DEFAULT FALSE,
    points_earned INTEGER,
    solved_at TIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES users(id),
    FOREIGN KEY(challenge_id) REFERENCES challenges(id)
);
```

## Operational Commands

### Service Management

```bash
# Start all services
docker compose up -d

# Stop all services
docker compose down

# View service logs
docker compose logs [service_name]

# View logs in real-time
docker compose logs -f

# Restart specific service
docker compose restart backend
```

### Container Access

```bash
# Execute command in container
docker exec <container_name> <command>

# Interactive shell access
docker exec -it <container_name> bash

# View container resource usage
docker compose ps -s
```

### Database Operations

```bash
# Access SQLite database
docker exec -it cyberforge-backend sqlite3 cyberforge.db

# Dump database schema
docker exec cyberforge-backend sqlite3 cyberforge.db .schema

# Reset database (destructive)
docker compose down -v
docker compose up --build
```

## Troubleshooting

### Service Fails to Start

**Symptom:** `Connection refused` on port 5000

**Diagnosis:**
```bash
docker compose logs backend
```

**Resolution:**
1. Verify `config.py` contains `sqlite:///cyberforge.db`
2. Check Docker daemon is running: `docker ps`
3. Rebuild containers: `docker compose down -v && docker compose up --build`

### SSH Connection Timeout

**Symptom:** `ssh: connect to host localhost port 2222: Connection refused`

**Diagnosis:**
```bash
docker compose ps | grep challenge
```

**Resolution:**
1. Verify challenge containers are running
2. Check port forwarding: `docker port cyberforge-ch1`
3. Wait 5-10 seconds for container initialization

### Database Connection Error

**Symptom:** `DatabaseError: Unable to open database file`

**Resolution:**
1. Verify database path in `config.py`
2. Check file permissions: `docker exec cyberforge-backend ls -la cyberforge.db`
3. Reset database: `docker compose down -v && docker compose up --build`

### CORS Errors in Browser Console

**Symptom:** `Access to XMLHttpRequest blocked by CORS policy`

**Resolution:**
1. Verify CORS middleware enabled in `backend/app.py`
2. Check API URL in frontend matches deployment (typically `http://localhost:5000`)
3. Restart backend: `docker compose restart backend`

## Testing

Run functional test suite:

```bash
# Navigate to test directory
cd tests

# Execute API tests
bash test_api.sh

# Execute SSH connectivity tests
bash test_ssh.sh
```

Tests verify:
- API endpoints responsive
- Database connectivity
- SSH challenge accessibility
- Flag validation logic
- User authentication flow

## System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| RAM | 4 GB | 8 GB |
| Storage | 5 GB | 10 GB |
| Disk I/O | 50 MB/s | 100+ MB/s |
| CPU Cores | 2 | 4+ |
| Operating System | Linux, macOS, Windows (WSL2) | Linux |

## Installation for Specific Platforms

### Linux (Ubuntu 20.04+)

```bash
sudo apt-get update
sudo apt-get install -y docker.io docker-compose
sudo usermod -aG docker $USER
# Log out and back in for group changes to take effect
newgrp docker
```

### macOS

```bash
# Install using Homebrew
brew install docker docker-compose

# Or download Docker Desktop
# https://www.docker.com/products/docker-desktop
```

### Windows (WSL2)

```bash
# Install WSL2
wsl --install

# Install Docker Desktop with WSL2 backend
# https://www.docker.com/products/docker-desktop

# Verify from PowerShell
wsl docker ps
```

## Development Workflow

### Making Code Changes

```bash
# Edit source files in local directory
vim backend/app.py

# Rebuild affected containers
docker compose up --build -d service_name

# View logs for verification
docker compose logs -f service_name
```

### Adding New Challenges

1. Create directory: `mkdir -p challenges/ch4`
2. Create `Dockerfile` with challenge environment
3. Update `docker-compose.yml` with new service definition
4. Insert challenge metadata into database
5. Rebuild: `docker compose up --build`

### Modifying Database Schema

1. Stop services: `docker compose down`
2. Update `models.py` with new schema
3. Reset database: `docker compose down -v`
4. Rebuild: `docker compose up --build`
5. Verify schema: `docker exec cyberforge-backend sqlite3 cyberforge.db .schema`

## Security Considerations

- Credentials stored as bcrypt hashes in database
- JWT tokens expire after configurable duration
- SSH challenge containers run with minimal privileges
- Database file permission restricted to container user
- No plain-text secrets in configuration files

## Performance Optimization

- Challenge containers allocate limited resources to prevent resource exhaustion
- SQLite appropriate for deployment patterns with <100 concurrent users
- Consider PostgreSQL for larger deployments (requires code modification)
- Static asset caching configured on frontend service

## License

MIT License - See repository for details

## Contributing

Report issues on GitHub repository issue tracker. Contributions accepted via pull request.

## Related Resources

- Docker documentation: https://docs.docker.com
- Flask API framework: https://flask.palletsprojects.com
- React frontend library: https://react.dev
- SQLite database: https://www.sqlite.org

---

**Current Version:** 2.0  
**Last Updated:** 2025-11-29  
**Status:** Stable
