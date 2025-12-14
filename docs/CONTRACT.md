# CyberForge Dev Contract (Core + Guardrails)

Дата: 2025-12-14

## 1) CANONICAL INVARIANTS (must not drift)
These are the rules that scripts/tests and the codebase must satisfy.

### Auth
- POST /api/login returns JSON with key: access_token (JWT)

### Flags
- POST /api/submit_flag returns JSON with key: correct (boolean)

### Smoke/E2E expectation
- Dev canonical test flag for challenge 1: flag{welcome_to_ssh}

## 2) DEV DEFAULTS (NOT CANON; may change)
Everything here is a convenience default and can be regenerated from docker-compose / scripts.

- Website base URL (default): http://localhost:3000
- Backend base URL (default): http://localhost:5000
- Juice Shop (default): http://localhost:3001
- PostgreSQL (default): localhost:5432
- Redis (default): localhost:6379
- SSH static ports (default): ch1=2222, ch2=2223, ch3=2224

## 3) SOURCE OF TRUTH
- Runtime snapshot: dumps/diagnostics/<timestamp>/*
- Compose: docker-compose.yml
- Tests: scripts/smoke_test.sh, scripts/user_flow_full.sh
