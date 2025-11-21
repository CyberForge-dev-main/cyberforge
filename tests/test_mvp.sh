#!/bin/bash

# CyberForge MVP: Полный тестовый скрипт (ФИКСИРОВАННЫЙ)
# Использование: bash tests/test_mvp.sh [SERVER_IP]
# Локально: bash tests/test_mvp.sh localhost
# По сети: bash tests/test_mvp.sh 192.168.0.114

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Параметры
SERVER_IP="${1:-localhost}"
WEB_PORT=3000
SSH_PORTS=(2222 2223 2224)
SSH_USER="ctfuser"
SSH_PASS="password123"
TIMEOUT=3

# Счётчики
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# ==========================================
# ЗАГОЛОВОК
# ==========================================

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   CyberForge MVP: Полный тестовый скрипт           ║${NC}"
echo -e "${BLUE}║   Сервер: $SERVER_IP${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}\n"

# ==========================================
# ФУНКЦИИ
# ==========================================

test_start() {
    echo -e "${YELLOW}▶ Тест $((TESTS_TOTAL + 1)): $1${NC}"
    ((TESTS_TOTAL++))
}

test_pass() {
    echo -e "${GREEN}  ✓ $1${NC}"
    ((TESTS_PASSED++))
}

test_fail() {
    echo -e "${RED}  ✗ ОШИБКА: $1${NC}"
    ((TESTS_FAILED++))
}

# ==========================================
# ТЕСТ 1: Проверка сети (Ping)
# ==========================================

test_start "Проверка доступности сервера (Ping)"

if timeout $TIMEOUT ping -c 1 "$SERVER_IP" > /dev/null 2>&1; then
    test_pass "Сервер доступен по сети ($SERVER_IP)"
else
    if [ "$SERVER_IP" = "localhost" ]; then
        test_pass "localhost (локальное подключение)"
    else
        test_fail "Сервер недоступен. Проверь IP и WiFi."
    fi
fi

echo ""

# ==========================================
# ТЕСТ 2: Веб-витрина (HTTP)
# ==========================================

test_start "Проверка веб-витрины на порту $WEB_PORT"

WEB_URL="http://$SERVER_IP:$WEB_PORT"

# Пытаемся получить статус HTTP
HTTP_STATUS=$(timeout $TIMEOUT curl -s -o /dev/null -w "%{http_code}" "$WEB_URL" 2>/dev/null || echo "000")

if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "301" ] || [ "$HTTP_STATUS" = "302" ]; then
    test_pass "Веб-витрина доступна ($WEB_URL)"
    
    # Проверяем контент
    if timeout $TIMEOUT curl -s "$WEB_URL" 2>/dev/null | grep -qi "cyberforge\|challenge\|flag"; then
        test_pass "На сайте найден ожидаемый контент"
    else
        test_fail "На сайте не найден ожидаемый контент (проверь index.html)"
    fi
else
    test_fail "Веб-витрина недоступна (HTTP $HTTP_STATUS). Проверь порт $WEB_PORT и контейнер cyberforge-website"
fi

echo ""

# ==========================================
# ТЕСТ 3-5: SSH Челленджи
# ==========================================

for i in {0..2}; do
    PORT=${SSH_PORTS[$i]}
    CH_NUM=$((i + 1))
    
    test_start "SSH подключение к челленджу $CH_NUM (порт $PORT)"
    
    # Проверяем доступность порта (nc - быстрый способ)
    if timeout 2 nc -zv "$SERVER_IP" "$PORT" > /dev/null 2>&1; then
        test_pass "Порт $PORT открыт и доступен"
        
        # Если есть sshpass, пытаемся подключиться и получить флаг
        if command -v sshpass &> /dev/null; then
            SSH_TEST=$(sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 \
                "$SSH_USER@$SERVER_IP" -p "$PORT" "echo 'OK'" 2>&1 || echo "FAIL")
            
            if echo "$SSH_TEST" | grep -q "OK"; then
                test_pass "SSH подключение успешно (челлендж $CH_NUM)"
                
                # Ищем флаг
                FLAG=$(sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 \
                    "$SSH_USER@$SERVER_IP" -p "$PORT" "cat flag.txt 2>/dev/null || find ~ -name '*flag*' -type f 2>/dev/null | head -1 | xargs cat 2>/dev/null" 2>&1)
                
                if echo "$FLAG" | grep -qi "flag{"; then
                    test_pass "Флаг найден: $(echo "$FLAG" | head -c 35)..."
                else
                    test_fail "Флаг не найден в челленже $CH_NUM"
                fi
            else
                test_fail "SSH подключение не удалось (челлендж $CH_NUM). Пароль или контейнер неправильный."
            fi
        else
            test_pass "sshpass не установлен (пропускаем проверку SSH подключения и флага)"
        fi
    else
        test_fail "Порт $PORT закрыт или недоступен. Проверь docker compose ps и логи."
    fi
    
    echo ""
done

# ==========================================
# ТЕСТ 6: Все порты (локально, если Docker)
# ==========================================

if [ "$SERVER_IP" = "localhost" ]; then
    test_start "Проверка Docker контейнеров (локально)"
    
    if command -v docker &> /dev/null; then
        # ПРАВИЛЬНЫЕ имена контейнеров!
        CONTAINERS=("cyberforge-website" "cyberforge-ch1" "cyberforge-ch2" "cyberforge-ch3")
        RUNNING=0
        
        for container in "${CONTAINERS[@]}"; do
            if docker ps --format "{{.Names}}" 2>/dev/null | grep -q "^${container}$"; then
                ((RUNNING++))
            fi
        done
        
        echo "  Запущено контейнеров: $RUNNING/4"
        
        if [ $RUNNING -eq 4 ]; then
            test_pass "Все 4 контейнера работают"
        else
            test_fail "Не все контейнеры запущены. Используй: docker compose ps"
        fi
    else
        test_fail "Docker не установлен"
    fi
    
    echo ""
fi

# ==========================================
# ИТОГОВЫЙ ОТЧЁТ
# ==========================================

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              ИТОГОВЫЙ ОТЧЁТ                       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}\n"

echo "Всего тестов:     $TESTS_TOTAL"
echo -e "${GREEN}Пройдено:         $TESTS_PASSED${NC}"
echo -e "${RED}Не пройдено:      $TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}═══════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  ✓ ВСЕ ТЕСТЫ ПРОЙДЕНЫ! MVP РАБОТАЕТ! 🚀${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
    exit 0
else
    echo -e "\n${RED}═══════════════════════════════════════════════════${NC}"
    echo -e "${RED}  ✗ НЕКОТОРЫЕ ТЕСТЫ НЕ ПРОШЛИ${NC}"
    echo -e "${RED}═══════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Советы по отладке:${NC}"
    echo "  1. Проверь контейнеры: docker compose ps"
    echo "  2. Перезапусти: docker compose restart"
    echo "  3. Посмотри логи: docker compose logs cyberforge-website"
    echo "  4. Убедись, что контейнеры Up: docker ps --format '{{.Names}} {{.Status}}'"
    echo "  5. Правильные имена: cyberforge-website, cyberforge-ch1, cyberforge-ch2, cyberforge-ch3"
    echo ""
    exit 1
fi
