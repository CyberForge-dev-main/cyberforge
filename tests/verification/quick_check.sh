#!/bin/bash

# ============================================================================
# БЫСТРАЯ ПРОВЕРКА
# ============================================================================

cd ~/Documents/cyberforge

echo "=== БЫСТРАЯ ПРОВЕРКА CYBERFORGE ==="
echo ""

echo "✓ Файлы:"
[ -f "docker-compose.yml" ] && echo "  ✓ docker-compose.yml" || echo "  ✗ docker-compose.yml"
[ -f "backend/app.py" ] && echo "  ✓ backend/app.py" || echo "  ✗ backend/app.py"
[ -f "package.json" ] && echo "  ✓ package.json" || echo "  ✗ package.json"

echo ""
echo "✓ Docker:"
docker compose ps 2>/dev/null | grep -q "Up" && echo "  ✓ Контейнеры" || echo "  ✗ Контейнеры"

echo ""
echo "✓ Порты:"
nc -z localhost 3000 2>/dev/null && echo "  ✓ :3000 Website" || echo "  ✗ :3000"
nc -z localhost 5000 2>/dev/null && echo "  ✓ :5000 Backend" || echo "  ✗ :5000"
nc -z localhost 2222 2>/dev/null && echo "  ✓ :2222 SSH Ch1" || echo "  ✗ :2222"

echo ""
echo "=== ЗАВЕРШЕНО ==="
