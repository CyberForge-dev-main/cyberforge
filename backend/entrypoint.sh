#!/bin/bash
set -e

# Start cleanup cron (every 5 minutes) - используем python3
echo "*/5 * * * * cd /app && /usr/local/bin/python3 cleanup_expired.py >> /var/log/cleanup.log 2>&1" | crontab -

# Start cron daemon
cron

# Start Gunicorn
exec gunicorn --config gunicorn.conf.py app:app
