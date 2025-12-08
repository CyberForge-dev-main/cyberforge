#!/usr/bin/env bash
# CyberForge Restore Script
set -euo pipefail

BACKUP_DIR="${HOME}/cyberforge_backups"

if [ $# -lt 1 ]; then
    echo "Usage: $0 <timestamp>"
    echo ""
    echo "Available backups:"
    ls -1 "${BACKUP_DIR}"/postgres_*.sql.gz | sed 's/.*postgres_\(.*\)\.sql\.gz/  \1/'
    exit 1
fi

TIMESTAMP=$1

echo "⚠️  RESTORE WILL OVERWRITE CURRENT DATA!"
echo "   Timestamp: ${TIMESTAMP}"
echo ""
read -p "Continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 0
fi

echo "🔄 Restoring from: ${TIMESTAMP}"

# 1. PostgreSQL restore
if [ -f "${BACKUP_DIR}/postgres_${TIMESTAMP}.sql.gz" ]; then
    echo "  📦 Restoring PostgreSQL..."
    gunzip -c "${BACKUP_DIR}/postgres_${TIMESTAMP}.sql.gz" \
      | docker exec -i cyberforge-db psql -U ctf_admin cyberforge
else
    echo "  ❌ PostgreSQL backup not found"
fi

# 2. Redis restore
if [ -f "${BACKUP_DIR}/redis_${TIMESTAMP}.rdb" ]; then
    echo "  📦 Restoring Redis..."
    docker compose stop redis
    docker cp "${BACKUP_DIR}/redis_${TIMESTAMP}.rdb" cyberforge-redis:/data/dump.rdb
    docker compose start redis
else
    echo "  ❌ Redis backup not found"
fi

# 3. .env restore
if [ -f "${BACKUP_DIR}/env_${TIMESTAMP}.env" ]; then
    echo "  📦 Restoring .env..."
    cp "${BACKUP_DIR}/env_${TIMESTAMP}.env" .env
else
    echo "  ❌ .env backup not found"
fi

echo "✅ Restore complete"
