#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

cd ~/Documents/cyberforge
echo "=== SECURITY CHECK ==="

check() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}OK${NC} $2"
    else
        echo -e "${RED}FAIL${NC} $2"
    fi
}

[ -f "backups/config.py.stable" ]; check $? "Backup"
[ -x ".git/hooks/pre-commit" ]; check $? "Hook"
[ -f "backend/CONFIG_SECURITY.md" ]; check $? "Docs"
[ -x "tests/verification/health_monitor.sh" ]; check $? "Monitor"
[ -x "tests/verification/auto_recover.sh" ]; check $? "Recovery"
[ -f "backend/init_database.py" ]; check $? "Init"
grep -q "sqlite:///cyberforge.db" backend/config.py; check $? "SQLite"
! grep -q "postgresql://" backend/config.py; check $? "NO Postgres"
curl -sf http://localhost:5000/api/health >/dev/null 2>&1; check $? "Backend"

echo ""
echo "=== ЗАВЕРШЕНО ==="
