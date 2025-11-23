#!/bin/bash

# ============================================================================
# ПРОВЕРКА DOCKER
# ============================================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

cd ~/Documents/cyberforge

echo "========================================="
echo "ПРОВЕРКА DOCKER"
echo "========================================="
echo ""

# 1. Статус
echo "[1/4] Статус контейнеров..."
docker compose ps

# 2. Порты
echo ""
echo "[2/4] Проверка портов..."
for port in 3000 5000 2222 2223 2224 3001; do
    if nc -z localhost $port 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Port $port: OPEN"
    else
        echo -e "${RED}✗${NC} Port $port: CLOSED"
    fi
done

# 3. Логи
echo ""
echo "[3/4] Логи (последние 5 строк)..."
echo -e "${BLUE}--- Website ---${NC}"
docker compose logs website --tail=5 2>/dev/null || echo "Не запущен"

echo ""
echo -e "${BLUE}--- Challenge 1 ---${NC}"
docker compose logs challenge-1 --tail=5 2>/dev/null || echo "Не запущен"

# 4. Образы
echo ""
echo "[4/4] Docker образы..."
docker images | grep cyberforge || echo "Образы не найдены"

echo ""
echo "========================================="
echo "ПРОВЕРКА DOCKER ЗАВЕРШЕНА"
echo "========================================="
