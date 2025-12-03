#!/bin/bash

# ============================================
# CyberForge Master Test Script
# Полная проверка системы в одном месте
# ============================================

FAILED=0
PASSED=0

NEED_DOCKER=0
if ! docker ps >/dev/null 2>&1; then
  echo "⚠️  Docker daemon не отвечает. Проверь, что Docker запущен."
  exit 1
fi

RUNNING_CONTAINERS=$(docker-compose ps -q | wc -l)
if [ "$RUNNING_CONTAINERS" -eq 0 ]; then
  echo "⚠️  docker-compose сервисы не запущены."
  read -p "   Запустить 'docker-compose up -d'? [y/N] " ans
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    docker-compose up -d
    NEED_DOCKER=1
  else
    echo "   Окей, тесты пойдут по тому, что есть."
  fi
fi



echo "╔════════════════════════════════════════════╗"
echo "║    CyberForge: Complete System Test        ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# ============================================
# Секция 1: Окружение
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  [1/6] Environment Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

check_command() {
  if command -v "$1" >/dev/null 2>&1; then
    echo "  ✅ $1"
    PASSED=$((PASSED + 1))
  else
    echo "  ❌ $1 not found"
    FAILED=$((FAILED + 1))
  fi
}

check_command docker
check_command docker-compose
check_command python3
check_command jq
check_command curl

echo ""

# ============================================
# Секция 2: Docker контейнеры
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  [2/6] Docker Containers"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

CONTAINERS=(
  "cyberforge-backend"
  "cyberforge-website"
  "cyberforge-juice-shop"
  "cyberforge-ch1"
  "cyberforge-ch2"
  "cyberforge-ch3"
)

for container in "${CONTAINERS[@]}"; do
  if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
    echo "  ✅ $container"
    PASSED=$((PASSED + 1))
  else
    echo "  ❌ $container not running"
    FAILED=$((FAILED + 1))
  fi
done

echo ""

# ============================================
# Секция 3: Сетевая доступность
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  [3/6] Network Ports"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

check_port() {
  local PORT=$1
  local NAME=$2
  if timeout 2 bash -c "curl -s http://localhost:${PORT} >/dev/null 2>&1" || \
     timeout 2 bash -c "nc -z localhost ${PORT} 2>/dev/null"; then
    echo "  ✅ ${NAME} (${PORT})"
    PASSED=$((PASSED + 1))
  else
    echo "  ❌ ${NAME} (${PORT})"
    FAILED=$((FAILED + 1))
  fi
}

check_port 5000 "Backend API"
check_port 3000 "Website"
check_port 3001 "Juice Shop"
check_port 2222 "SSH Challenge 1"
check_port 2223 "SSH Challenge 2"
check_port 2224 "SSH Challenge 3"

echo ""

# ============================================
# Секция 4: Backend API проверки
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  [4/6] Backend API"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

BASE_URL="http://localhost:5000"

# Проверка /api/challenges
CHALS=$(curl -s "${BASE_URL}/api/challenges" 2>/dev/null || echo "")
if echo "$CHALS" | jq -e '.[0].id' >/dev/null 2>&1; then
  echo "  ✅ GET /api/challenges"
  PASSED=$((PASSED + 1))
else
  echo "  ❌ GET /api/challenges"
  FAILED=$((FAILED + 1))
fi

# Проверка health endpoint
HEALTH=$(curl -s -w "%{http_code}" "${BASE_URL}/" -o /dev/null 2>/dev/null || echo "000")
if [ "$HEALTH" = "200" ] || [ "$HEALTH" = "404" ]; then
  echo "  ✅ Backend responding"
  PASSED=$((PASSED + 1))
else
  echo "  ❌ Backend not responding"
  FAILED=$((FAILED + 1))
fi

echo ""

# ============================================
# Секция 5: User Flow E2E
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  [5/6] User Flow E2E Test"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -f ./tests/user_flow_full.sh ]; then
  if ./tests/user_flow_full.sh >/dev/null 2>&1; then
    echo "  ✅ User flow E2E passed"
    PASSED=$((PASSED + 1))
  else
    echo "  ❌ User flow E2E failed"
    FAILED=$((FAILED + 1))
    echo "     Run './tests/user_flow_full.sh' for details"
  fi
else
  echo "  ⚠️  user_flow_full.sh not found"
fi

echo ""

# ============================================
# Секция 6: Rate Limit
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  [6/6] Rate Limit Test"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -f ./tests/test_rate_limit.sh ]; then
  if ./tests/test_rate_limit.sh >/dev/null 2>&1; then
    echo "  ✅ Rate limit test passed"
    PASSED=$((PASSED + 1))
  else
    echo "  ❌ Rate limit test failed"
    FAILED=$((FAILED + 1))
    echo "     Run './tests/test_rate_limit.sh' for details"
  fi
else
  echo "  ⚠️  test_rate_limit.sh not found"
fi

echo ""

collect_artifacts() {
  ART_DIR="./artifacts"
  mkdir -p "$ART_DIR"

  echo "Сохраняю артефакты в ${ART_DIR}/"

  docker-compose ps > "${ART_DIR}/docker_ps.txt" 2>&1 || true
  docker-compose logs > "${ART_DIR}/docker_logs.txt" 2>&1 || true
  docker stats --no-stream > "${ART_DIR}/docker_stats.txt" 2>&1 || true

  # Базовый снимок backend API, если доступен
  curl -s "http://localhost:5000/api/challenges" > "${ART_DIR}/challenges.json" 2>/dev/null || true
}


# ============================================
# Итоговый отчёт
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  SUMMARY                                   "
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ Passed: $PASSED"
echo "  ❌ Failed: $FAILED"
echo ""

# Если поднимали стек сами в рамках теста — можно тут его погасить (опционально)
# if [ "$NEED_DOCKER" -eq 1 ]; then
#   echo "Stopping docker-compose stack started by test.sh..."
#   docker-compose down -v
# fi

if [ "$FAILED" -eq 0 ]; then
  echo "╔════════════════════════════════════════════╗"
  echo "║   🎉  ALL TESTS PASSED                     ║"
  echo "╚════════════════════════════════════════════╝"
  exit 0
else
  echo "╔════════════════════════════════════════════╗"
  echo "║   ⚠️   SOME TESTS FAILED                    ║"
  echo "╚════════════════════════════════════════════╝"
  collect_artifacts
  exit 1
fi
