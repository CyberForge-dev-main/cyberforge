#!/bin/bash

# ============================================================================
# ПРОВЕРКА BACKEND API
# ============================================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

cd ~/Documents/cyberforge

echo "========================================="
echo "ПРОВЕРКА BACKEND API"
echo "========================================="
echo ""

# 1. Файлы
echo "[1/7] Файлы backend..."
for file in app.py config.py models.py auth.py requirements.txt Dockerfile; do
    if [ -f "backend/$file" ]; then
        echo -e "${GREEN}✓${NC} backend/$file"
    else
        echo -e "${RED}✗${NC} backend/$file"
    fi
done

# 2. Config
echo ""
echo "[2/7] Config.py..."
if grep -q "sqlite:///" backend/config.py; then
    echo -e "${GREEN}✓${NC} SQLite URI"
else
    echo -e "${RED}✗${NC} SQLite URI не найден"
fi

if grep -q "postgresql://" backend/config.py; then
    echo -e "${RED}✗ ПРЕДУПРЕЖДЕНИЕ:${NC} Найден PostgreSQL URI"
fi

# 3. Dependencies
echo ""
echo "[3/7] Requirements..."
cat backend/requirements.txt

# 4. Флаги
echo ""
echo "[4/7] Флаги в app.py..."
grep -o 'flag{[^}]*}' backend/app.py | nl

# 5. БД
echo ""
echo "[5/7] База данных..."
if [ -f "backend/cyberforge.db" ]; then
    echo -e "${GREEN}✓${NC} cyberforge.db"
    du -h backend/cyberforge.db
    
    if command -v sqlite3 &> /dev/null; then
        echo "Таблицы:"
        sqlite3 backend/cyberforge.db ".tables"
    fi
else
    echo -e "${YELLOW}⚠${NC} cyberforge.db не найден"
fi

# 6. Endpoints
echo ""
echo "[6/7] API routes..."
grep "@app.route" backend/app.py | nl

# 7. Health
echo ""
echo "[7/7] Health check..."
if curl -sf http://localhost:5000/api/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Backend отвечает:"
    curl -s http://localhost:5000/api/health | python3 -m json.tool
else
    echo -e "${YELLOW}⚠${NC} Backend не отвечает"
fi

echo ""
echo "========================================="
echo "ПРОВЕРКА BACKEND ЗАВЕРШЕНА"
echo "========================================="
