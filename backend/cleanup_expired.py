#!/usr/bin/env python3
"""Cleanup expired challenge containers"""

import os
import sys
from datetime import datetime

sys.path.insert(0, os.path.dirname(__file__))

from app import app
from models import db, ChallengeInstance
from pool_manager import pool_manager

def cleanup_expired_containers():
    """Find and remove expired containers"""
    with app.app_context():
        now = datetime.utcnow()
        
        expired = ChallengeInstance.query.filter(
            ChallengeInstance.status == 'running',
            ChallengeInstance.expires_at < now
        ).all()
        
        print(f"🔍 Found {len(expired)} expired containers")
        
        cleaned = 0
        for instance in expired:
            print(f"🗑️  Cleaning up: {instance.container_name}")
            
            # Try to stop container (ignore if already stopped/removed)
            pool_manager.release_container(instance.container_name)
            
            # Always mark as expired in DB, even if container doesn't exist
            instance.status = 'expired'
            db.session.commit()
            cleaned += 1
            print(f"✅ Marked as expired: {instance.container_name}")
        
        print(f"✅ Cleanup complete. Processed {cleaned} containers")

if __name__ == '__main__':
    cleanup_expired_containers()
