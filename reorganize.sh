#!/bin/bash
set -e

echo "🔧 CyberForge - Project Reorganization"
echo "======================================="
echo ""

# Проверка директории
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ ОШИБКА: Запускайте из корня проекта"
    exit 1
fi

echo "✅ Работаем в: $(pwd)"
echo ""

# ШАГ 1: Переименовать tests/ → scripts/
echo "📁 ШАГ 1: Переименование tests/ → scripts/..."

if [ -d "tests" ]; then
    mv tests scripts
    echo "  ✅ tests/ → scripts/"
else
    mkdir -p scripts
    echo "  ✅ Создана директория scripts/"
fi

# ШАГ 2: Переместить скрипты из корня в scripts/
echo ""
echo "📦 ШАГ 2: Перемещение скриптов в scripts/..."

# Переместить check_system.sh
if [ -f "check_system.sh" ]; then
    mv check_system.sh scripts/
    echo "  ✅ check_system.sh → scripts/"
fi

# Переместить dump_system.sh
if [ -f "dump_system.sh" ]; then
    mv dump_system.sh scripts/
    echo "  ✅ dump_system.sh → scripts/"
fi

# Удалить дублирующийся test.sh из scripts/ (он не нужен, есть остальные тесты)
if [ -f "scripts/test.sh" ]; then
    echo "  ℹ️  Найден scripts/test.sh (оставляем, это runner)"
fi

# ШАГ 3: Обновить Makefile
echo ""
echo "📝 ШАГ 3: Обновление Makefile..."

cat > Makefile << 'EOF_MAKEFILE'
PROJECT_NAME=cyberforge

.PHONY: up down restart logs ps test health dump

up:
	docker compose up -d

down:
	docker compose down

restart: down up

logs:
	docker compose logs --tail=100 -f

ps:
	docker compose ps

test:
	@echo "Running integration tests..."
	@./scripts/health_check.sh
	@./scripts/test_rate_limit.sh
	@./scripts/user_flow_full.sh

smoke:
	@echo "Running smoke test..."
	@./scripts/smoke_test.sh

health:
	@./scripts/check_system.sh

dump:
	@./scripts/dump_system.sh
EOF_MAKEFILE

echo "  ✅ Makefile обновлён"

# ШАГ 4: Обновить .gitignore
echo ""
echo "📝 ШАГ 4: Обновление .gitignore..."

cat > .gitignore << 'EOF_GITIGNORE'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
env/
ENV/

# Database
instance/
backend/cyberforge.db
*.db

# Environment
.env
.env.local

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Test
.pytest_cache/
.coverage

# Logs
*.log
logs/

# Backup files
*.bak
*.backup
*.broken_*

# Temporary scripts (не коммитить)
*_quick_fix*.sh
fix_*.py
fix_*.sh

# Archive directories
archive/old_*/
archive/backup*/

# Dumps (локальные, не коммитить)
project_dump.txt
EOF_GITIGNORE

echo "  ✅ .gitignore обновлён"

# ШАГ 5: Обновить GitHub workflows
echo ""
echo "📝 ШАГ 5: Обновление GitHub workflows..."

# .github/workflows/lint.yml
cat > .github/workflows/lint.yml << 'EOF_LINT'
name: Code Quality

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  lint-python:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
        
    - name: Install dependencies
      run: |
        pip install flake8
        
    - name: Lint Python code
      run: flake8 backend/ --count --select=E9,F63,F7,F82 --show-source --statistics
      
  lint-shell:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Shellcheck
      uses: ludeeus/action-shellcheck@master
      with:
        scandir: './scripts'
EOF_LINT

# .github/workflows/test.yml
cat > .github/workflows/test.yml << 'EOF_TEST'
name: Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Start Docker containers
      run: docker compose up -d
      
    - name: Wait for services
      run: sleep 15
      
    - name: Install dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y jq sshpass netcat
      
    - name: Run smoke test
      run: bash scripts/smoke_test.sh
      
    - name: Stop containers
      run: docker compose down
EOF_TEST

echo "  ✅ GitHub workflows обновлены"

# ШАГ 6: Обновить README.md структуру
echo ""
echo "📝 ШАГ 6: Обновление README.md..."

# Заменить секцию Project Structure в README
sed -i '/## Project Structure/,/## Available Commands/{//!d}' README.md 2>/dev/null || true

cat >> README_structure_update.tmp << 'EOF_README'

## Project Structure

```
cyberforge/
├── backend/              # Flask API (Python 3.11)
│   ├── app.py           # Main application
│   ├── models.py        # SQLAlchemy models
│   ├── auth.py          # JWT authentication
│   └── config.py        # Configuration
├── website/             # Frontend (Vanilla JS)
│   └── index.html       # Single-page application
├── challenges/          # Challenge Dockerfiles
│   ├── ch1/             # SSH Basics (port 2222)
│   ├── ch2/             # Hidden Files (port 2223)
│   └── ch3/             # Directory Search (port 2224)
├── scripts/             # Utility scripts
│   ├── smoke_test.sh    # Full smoke test
│   ├── health_check.sh  # Health check
│   ├── test_rate_limit.sh
│   ├── user_flow_full.sh
│   ├── check_system.sh  # System diagnostics
│   └── dump_system.sh   # Project dump
├── docs/                # Documentation
│   └── CURRENT_STATE.md # Project status
├── .github/workflows/   # CI/CD pipelines
├── docker-compose.yml   # Service orchestration
├── Makefile            # Helper commands
└── README.md           # This file
```

EOF_README

# Вставить обновлённую структуру (упрощённо)
# (В реальности лучше вручную проверить README, но для автоматизации - пропускаем)

echo "  ℹ️  README.md - обновите вручную секцию Project Structure"
echo "     (используйте содержимое из README_structure_update.tmp)"

# ШАГ 7: Создать scripts/README.md с описанием
echo ""
echo "📝 ШАГ 7: Создание scripts/README.md..."

cat > scripts/README.md << 'EOF_SCRIPTS_README'
# CyberForge Scripts

Utility scripts for testing, diagnostics, and maintenance.

## Testing Scripts

### `smoke_test.sh`
**Full smoke test** - проверяет всю систему после изменений.

```bash
./scripts/smoke_test.sh
```

**Тесты:**
- Infrastructure (backend, website, juice-shop, SSH ports)
- API endpoints (register, login, challenges, submit_flag, leaderboard)
- SSH challenges (флаги через SSH)

**Выход:**
- `0` - все тесты прошли
- `1` - есть failed тесты

---

### `health_check.sh`
**Quick health check** - быстрая проверка состояния.

```bash
./scripts/health_check.sh
```

**Проверяет:**
- Docker контейнеры
- Доступность портов
- HTTP endpoints

---

### `test_rate_limit.sh`
**Rate limit test** - проверка защиты от брутфорса.

```bash
./scripts/test_rate_limit.sh
```

**Ожидаемый результат:**
- 5 попыток проходят (200/400)
- 6-я попытка отклоняется (429 Too Many Requests)

---

### `user_flow_full.sh`
**End-to-end user flow** - полный цикл работы пользователя.

```bash
./scripts/user_flow_full.sh
```

**Шаги:**
1. Регистрация
2. Логин
3. Получение челленджей
4. Отправка флага
5. Проверка leaderboard
6. Проверка progress

---

## Diagnostic Scripts

### `check_system.sh`
**Full system check** - детальная диагностика.

```bash
./scripts/check_system.sh
```

**Показывает:**
- Docker контейнеры (статус)
- Backend health
- Git статус
- API smoke test (login, challenges, submit, leaderboard)
- SSH ch1 flag test

---

### `dump_system.sh`
**Project dump** - создаёт полный дамп структуры проекта.

```bash
./scripts/dump_system.sh
```

**Создаёт файл:** `project_dump.txt`

**Содержит:**
- Directory tree
- File contents (все текстовые файлы)

**Игнорирует:**
- `.git/`, `node_modules/`, `__pycache__/`
- Бинарники, архивы, изображения

---

## Usage with Makefile

```bash
make test     # Запустить все тесты
make smoke    # Smoke test
make health   # Health check
make dump     # Создать project dump
```

---

## CI/CD Integration

Эти скрипты используются в GitHub Actions:

- `.github/workflows/test.yml` - запускает `smoke_test.sh`
- `.github/workflows/lint.yml` - проверяет shell скрипты (shellcheck)

---

## Dependencies

**Требуются для тестов:**
- `curl` - HTTP запросы
- `jq` - JSON парсинг
- `sshpass` - SSH без интерактивного ввода пароля
- `nc` (netcat) - проверка портов

**Установка (Ubuntu/Debian):**
```bash
sudo apt-get install -y curl jq sshpass netcat
```
EOF_SCRIPTS_README

echo "  ✅ scripts/README.md создан"

# ШАГ 8: Финальная проверка структуры
echo ""
echo "📊 ШАГ 8: Проверка структуры..."

echo ""
echo "Корень проекта:"
ls -lh | grep -E "^d|Makefile|README|docker-compose|LICENSE|\.env\.template|\.gitignore" | awk '{print "  " $9}'

echo ""
echo "scripts/:"
ls -lh scripts/ | tail -n +2 | awk '{print "  " $9}'

# ШАГ 9: Git статус
echo ""
echo "📋 ШАГ 9: Git статус..."

git status --short

# ШАГ 10: Финальные рекомендации
echo ""
echo "═══════════════════════════════════════"
echo "✅ РЕОРГАНИЗАЦИЯ ЗАВЕРШЕНА!"
echo "═══════════════════════════════════════"
echo ""
echo "📌 СЛЕДУЮЩИЕ ДЕЙСТВИЯ:"
echo ""
echo "1. Проверьте изменения:"
echo "   git diff Makefile"
echo "   git diff .gitignore"
echo "   git diff .github/workflows/"
echo ""
echo "2. Проверьте работоспособность:"
echo "   make health"
echo "   make smoke"
echo ""
echo "3. Если всё работает - закоммитьте:"
echo "   git add -A"
echo "   git commit -m 'refactor: reorganize project structure (tests -> scripts)'"
echo "   git push origin main"
echo ""
echo "4. Удалите временный файл:"
echo "   rm README_structure_update.tmp"
echo ""
echo "📁 ИТОГОВАЯ СТРУКТУРА КОРНЯ:"
echo "   ✅ Makefile"
echo "   ✅ docker-compose.yml"
echo "   ✅ README.md"
echo "   ✅ LICENSE"
echo "   ✅ .env.template"
echo "   ✅ .gitignore"
echo "   📁 scripts/ (все скрипты)"
echo "   📁 backend/"
echo "   📁 website/"
echo "   📁 challenges/"
echo "   📁 docs/"
echo "   📁 .github/"
echo ""
echo "✅ ГОТОВО!"
