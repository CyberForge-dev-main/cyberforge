#!/bin/bash

# 🚀 CyberForge Phase 1: Automated Scaffold Script
# Этот скрипт автоматически создаёт всю структуру Фазы 1
# Использование: bash scaffold_phase1.sh

set -e

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Счётчики
STEPS=0
COMPLETED=0
FAILED=0

# ==========================================
# ФУНКЦИИ
# ==========================================

step_start() {
    ((STEPS++))
    echo -e "${YELLOW}▶ Шаг $STEPS: $1${NC}"
}

step_success() {
    echo -e "${GREEN}  ✓ $1${NC}"
    ((COMPLETED++))
}

step_error() {
    echo -e "${RED}  ✗ ОШИБКА: $1${NC}"
    ((FAILED++))
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        step_error "$1 не установлен. Установи: sudo apt install $1"
        return 1
    fi
    return 0
}

# ==========================================
# НАЧАЛО
# ==========================================

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   CyberForge Phase 1: Automated Scaffold            ║${NC}"
echo -e "${BLUE}║   Создание Backend + Frontend структуры             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}\n"

# ==========================================
# ПРОВЕРКА ПРЕДУСЛОВИЙ
# ==========================================

step_start "Проверка предусловий"

cd ~/Documents/cyberforge || (step_error "Директория ~/Documents/cyberforge не найдена" && exit 1)
step_success "Директория cyberforge найдена"

check_command "python3" || exit 1
step_success "Python3 установлен"

check_command "npm" || exit 1
step_success "NPM установлен"

check_command "git" || exit 1
step_success "Git установлен"

check_command "docker" || exit 1
step_success "Docker установлен"

echo ""

# ==========================================
# ЭТАП 1: SCRIPTS
# ==========================================

step_start "Создание папки scripts/"
mkdir -p scripts
step_success "Папка scripts создана"

echo ""
step_start "Создание скрипта validate.sh"

cat > scripts/validate.sh << 'EOF'
#!/bin/bash
set -e

echo "🔍 Валидация CyberForge Фаза 1..."

echo "▶ Проверка docker-compose..."
docker compose config > /dev/null && echo "✓ docker-compose OK" || (echo "✗ Ошибка docker" && exit 1)

echo "▶ Проверка структуры файлов..."
test -d backend && echo "✓ Папка backend есть" || echo "⚠ Папка backend отсутствует"
test -d frontend && echo "✓ Папка frontend есть" || echo "⚠ Папка frontend отсутствует"

echo "▶ Проверка Git..."
git status > /dev/null && echo "✓ Git OK" || (echo "✗ Git ошибка" && exit 1)

echo ""
echo "✅ БАЗОВЫЕ ПРОВЕРКИ ПРОЙДЕНЫ!"
echo ""
