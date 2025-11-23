#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

cd ~/Documents/cyberforge

if ! curl -sf http://localhost:5000/api/health >/dev/null 2>&1; then
    echo -e "${RED}Backend не отвечает${NC}"
    
    if ! grep -q "sqlite:///cyberforge.db" backend/config.py; then
        echo -e "${YELLOW}Восстановление...${NC}"
        
        if [ -f "backups/config.py.stable" ]; then
            cp backups/config.py.stable backend/config.py
        else
            cat > backend/config.py << 'CFG'
import os
class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-key'
    SQLALCHEMY_DATABASE_URI = 'sqlite:///cyberforge.db'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY') or 'jwt-key'
CFG
        fi
    fi
    
    docker compose restart backend
    sleep 10
    
    curl -sf http://localhost:5000/api/health >/dev/null 2>&1 \
        && echo -e "${GREEN}Восстановлен${NC}" \
        || echo -e "${RED}Не удалось${NC}"
else
    echo -e "${GREEN}Система OK${NC}"
fi
