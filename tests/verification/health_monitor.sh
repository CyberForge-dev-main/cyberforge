#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

while true; do
    clear
    echo "=== HEALTH MONITOR ==="
    echo "$(date +%H:%M:%S)"
    echo ""
    
    grep -q "sqlite:///cyberforge.db" ~/Documents/cyberforge/backend/config.py \
        && echo -e "${GREEN}OK${NC} Config" \
        || echo -e "${RED}FAIL${NC} Config"
    
    curl -sf http://localhost:5000/api/health >/dev/null 2>&1 \
        && echo -e "${GREEN}OK${NC} Backend" \
        || echo -e "${RED}FAIL${NC} Backend"
    
    echo ""
    echo "Обновление 30с... Ctrl+C выход"
    sleep 30
done
