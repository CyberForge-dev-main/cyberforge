#!/bin/bash

# ============================================================================
# ПРОВЕРКА БАЗЫ ДАННЫХ
# ============================================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

DB_PATH="$HOME/Documents/cyberforge/backend/cyberforge.db"

echo "========================================="
echo "ПРОВЕРКА БАЗЫ ДАННЫХ"
echo "========================================="
echo ""

# 1. Существование
echo "[1/5] Файл БД..."
if [ -f "$DB_PATH" ]; then
    echo -e "${GREEN}✓${NC} $DB_PATH"
    du -h "$DB_PATH"
else
    echo -e "${RED}✗${NC} БД не найдена"
    exit 0
fi

# 2. sqlite3
echo ""
echo "[2/5] sqlite3..."
if command -v sqlite3 &> /dev/null; then
    echo -e "${GREEN}✓${NC} sqlite3 установлен"
else
    echo -e "${RED}✗${NC} sqlite3 не установлен"
    exit 1
fi

# 3. Таблицы
echo ""
echo "[3/5] Таблицы..."
sqlite3 "$DB_PATH" ".tables"

# 4. Challenges
echo ""
echo "[4/5] Содержимое challenges..."
sqlite3 "$DB_PATH" "SELECT id, name, flag FROM challenges;" 2>/dev/null || echo "Пусто"

# 5. Дамп
echo ""
echo "[5/5] Создание дампа..."
sqlite3 "$DB_PATH" ".dump" > database_dump.sql
echo -e "${GREEN}✓${NC} Сохранено в database_dump.sql"

echo ""
echo "========================================="
echo "ПРОВЕРКА БД ЗАВЕРШЕНА"
echo "========================================="
