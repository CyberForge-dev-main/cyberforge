#!/usr/bin/env bash
# CyberForge Backup Script
set -euo pipefail

BACKUP_DIR="${HOME}/cyberforge_backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "${BACKUP_DIR}"

echo "🔄 Starting backup: ${TIMESTAMP}"

# 1. PostgreSQL dump
echo "  📦 Backing up PostgreSQL..."
docker exec cyberforge-db pg_dump -U ctf_admin cyberforge \
  | gzip > "${BACKUP_DIR}/postgres_${TIMESTAMP}.sql.gz"

# 2. Redis snapshot
echo "  📦 Backing up Redis..."
docker exec cyberforge-redis redis-cli SAVE > /dev/null
docker cp cyberforge-redis:/data/dump.rdb "${BACKUP_DIR}/redis_${TIMESTAMP}.rdb"

# 3. Project dump
echo "  📦 Creating project dump..."
cd "${PROJECT_ROOT}"
./dump_system.sh
cp project_dump.txt "${BACKUP_DIR}/project_dump_${TIMESTAMP}.txt"

# 4. .env backup
echo "  📦 Backing up .env..."
cp "${PROJECT_ROOT}/.env" "${BACKUP_DIR}/env_${TIMESTAMP}.env"

# 5. Clean old backups (keep last 7 days)
echo "  🧹 Cleaning old backups..."
find "${BACKUP_DIR}" -type f -mtime +7 -delete

echo "✅ Backup complete: ${BACKUP_DIR}"
ls -lh "${BACKUP_DIR}" | tail -5
