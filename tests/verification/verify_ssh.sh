#!/bin/bash

# ============================================================================
# ПРОВЕРКА SSH ЧЕЛЛЕНДЖЕЙ
# ============================================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

cd ~/Documents/cyberforge

echo "========================================="
echo "ПРОВЕРКА SSH ЧЕЛЛЕНДЖЕЙ"
echo "========================================="
echo ""

# Проверка портов
for port in 2222 2223 2224; do
    echo "Проверка порта $port..."
    if nc -z localhost $port 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Порт $port доступен"
    else
        echo -e "${RED}✗${NC} Порт $port ЗАКРЫТ"
    fi
    echo ""
done

# Проверка Dockerfiles
echo "========================================="
echo "ПРОВЕРКА DOCKERFILES"
echo "========================================="
echo ""

for i in 1 2 3; do
    dockerfile="Dockerfile.ch$i"
    echo "[$dockerfile]"
    
    if [ -f "$dockerfile" ]; then
        echo -e "${GREEN}✓${NC} Существует"
        echo "Флаги:"
        grep -o 'flag{[^}]*}' "$dockerfile" || echo "  (не найдены)"
    else
        echo -e "${RED}✗${NC} НЕ НАЙДЕН"
    fi
    echo ""
done

echo "========================================="
echo "ПРОВЕРКА SSH ЗАВЕРШЕНА"
echo "========================================="
