#!/bin/bash

echo "========================================="
echo "🔍 CYBERFORGE FULL DIAGNOSTIC"
echo "========================================="
echo ""

# 1. СТРУКТУРА ПРОЕКТА
echo "=== 1. PROJECT STRUCTURE ==="
tree -L 2 -I 'node_modules|__pycache__|*.pyc' || find . -maxdepth 2 -type d
echo ""

# 2. DOCKER CONTAINERS STATUS
echo "=== 2. DOCKER CONTAINERS STATUS ==="
docker compose ps
echo ""

# 3. DOCKER COMPOSE CONFIG
echo "=== 3. DOCKER COMPOSE CONFIG (backend section) ==="
grep -A 15 "backend:" docker-compose.yml
echo ""

# 4. BACKEND FILES
echo "=== 4. BACKEND FILES ==="
ls -lh backend/*.py
echo ""

# 5. BACKEND DEPENDENCIES
echo "=== 5. BACKEND REQUIREMENTS ==="
cat backend/requirements.txt
echo ""

# 6. DATABASE STATUS
echo "=== 6. DATABASE CHECK ==="
docker compose exec -T db psql -U ctf_admin -d ctf_db -c "\dt" 2>&1 || echo "❌ DB not accessible"
echo ""

# 7. BACKEND LOGS (last 30 lines)
echo "=== 7. BACKEND LOGS (last 30) ==="
docker compose logs backend --tail=30 2>&1 || echo "❌ Backend not running"
echo ""

# 8. NETWORK
echo "=== 8. DOCKER NETWORK ==="
docker network ls | grep cyberforge
echo ""

# 9. IMAGES
echo "=== 9. DOCKER IMAGES ==="
docker images | grep -E "cyberforge|REPOSITORY"
echo ""

# 10. API HEALTH CHECK
echo "=== 10. API HEALTH CHECK ==="
curl -s http://localhost:5000/api/health | jq 2>/dev/null || echo "❌ API not responding"
echo ""

# 11. CHALLENGES API
echo "=== 11. CHALLENGES API ==="
curl -s http://localhost:5000/api/challenges | jq 2>/dev/null || echo "❌ Challenges API not responding"
echo ""

# 12. STATIC CHALLENGE CONTAINERS
echo "=== 12. STATIC CHALLENGE CONTAINERS ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "NAMES|ch1|ch2|ch3|juice"
echo ""

# 13. POOL_MANAGER.PY CHECK
echo "=== 13. POOL_MANAGER.PY (first 50 lines) ==="
head -50 backend/pool_manager.py
echo ""

# 14. APP.PY ROUTES CHECK
echo "=== 14. APP.PY ROUTES (assign/release) ==="
grep -n "assign_challenge\|release_challenge" backend/app.py | head -10
echo ""

# 15. MODELS.PY CHECK
echo "=== 15. MODELS.PY (ChallengeInstance) ==="
grep -A 10 "class ChallengeInstance" backend/models.py
echo ""

echo "========================================="
echo "✅ DIAGNOSTIC COMPLETE!"
echo "========================================="
