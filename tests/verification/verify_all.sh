#!/bin/bash

# ============================================================================
# CYBERFORGE — ПОЛНАЯ ВЕРИФИКАЦИЯ v2.1
# ============================================================================

# НЕ используем set -e чтобы скрипт продолжал работать при ошибках

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASSED=0
FAILED=0
WARNINGS=0

print_header() {
    echo ""
    echo "========================================"
    echo "$1"
    echo "========================================"
    echo ""
}

print_pass() {
    echo "[PASS] $1"
    ((PASSED++)) || true
}

print_fail() {
    echo "[FAIL] $1"
    ((FAILED++)) || true
}

print_warn() {
    echo "[WARN] $1"
    ((WARNINGS++)) || true
}

cd ~/Documents/cyberforge || exit 1

print_header "0. ОКРУЖЕНИЕ"

if command -v docker &> /dev/null; then
    print_pass "Docker: $(docker --version)"
else
    print_fail "Docker не установлен"
fi

if docker compose version &> /dev/null 2>&1; then
    print_pass "Docker Compose"
else
    print_fail "Docker Compose не установлен"
fi

if command -v python3 &> /dev/null; then
    print_pass "Python3: $(python3 --version)"
else
    print_fail "Python3 не установлен"
fi

print_header "1. СТРУКТУРА ФАЙЛОВ"

for file in docker-compose.yml README.md backend/app.py backend/config.py package.json; do
    [ -f "$file" ] && print_pass "$file" || print_fail "$file НЕ НАЙДЕН"
done

print_header "2. DOCKER COMPOSE"

if docker compose config > /dev/null 2>&1; then
    print_pass "docker-compose.yml валиден"
else
    print_fail "docker-compose.yml содержит ошибки"
fi

print_header "3. КОНТЕЙНЕРЫ"

docker compose ps 2>/dev/null
RUNNING=$(docker compose ps -q 2>/dev/null | wc -l)
if [ "$RUNNING" -gt 0 ]; then
    print_pass "Контейнеров: $RUNNING"
else
    print_warn "Контейнеры не запущены"
fi

print_header "4. BACKEND CONFIG"

if [ -f "backend/config.py" ]; then
    if grep -q "sqlite:///" backend/config.py 2>/dev/null; then
        print_pass "SQLite в config.py"
    elif grep -q "postgresql://" backend/config.py 2>/dev/null; then
        print_fail "PostgreSQL в config.py (должен быть SQLite)"
    else
        print_warn "URI не найден в config.py"
    fi
else
    print_fail "backend/config.py не найден"
fi

print_header "5. ПОРТЫ"

for port in 3000 5000 2222 2223 2224; do
    if nc -z localhost $port 2>/dev/null; then
        print_pass "Порт :$port открыт"
    else
        print_warn "Порт :$port закрыт"
    fi
done

print_header "6. BACKEND API"

if curl -sf http://localhost:5000/api/health > /dev/null 2>&1; then
    print_pass "Backend API отвечает"
    curl -s http://localhost:5000/api/health
else
    print_fail "Backend API не отвечает на :5000"
fi

print_header "7. БАЗА ДАННЫХ"

if [ -f "backend/cyberforge.db" ]; then
    print_pass "cyberforge.db существует"
    du -h backend/cyberforge.db
else
    print_warn "cyberforge.db не найден"
fi

print_header "8. GIT"

[ -d ".git" ] && print_pass "Git репозиторий" || print_warn "Git не инициализирован"

print_header "ИТОГ"

TOTAL=$((PASSED + FAILED + WARNINGS))
echo "Пройдено: $PASSED"
echo "Провалено: $FAILED"
echo "Предупреждений: $WARNINGS"
echo "Всего проверок: $TOTAL"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "ВСЕ КРИТИЧЕСКИЕ ПРОВЕРКИ ПРОЙДЕНЫ"
    exit 0
else
    echo "ОБНАРУЖЕНЫ ОШИБКИ:"
    echo ""
    [ -f "backend/config.py" ] && grep -q "postgresql://" backend/config.py 2>/dev/null && \
        echo "  1. Backend config.py использует PostgreSQL вместо SQLite"
    ! nc -z localhost 5000 2>/dev/null && \
        echo "  2. Backend не отвечает на порту :5000"
    ! [ -f "backend/cyberforge.db" ] && \
        echo "  3. База данных не создана"
    exit 1
fi
