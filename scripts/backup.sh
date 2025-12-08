#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./backups"
mkdir -p $BACKUP_DIR
cp backend/instance/cyberforge.db $BACKUP_DIR/cyberforge_$DATE.db
cp .env $BACKUP_DIR/.env_$DATE
find $BACKUP_DIR -name "*.db" -mtime +7 -delete
echo "✅ Backup complete: $DATE"
