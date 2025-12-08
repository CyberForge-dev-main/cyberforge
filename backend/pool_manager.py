#!/usr/bin/env python3
"""Challenge Container Pool Manager"""

import subprocess
from datetime import datetime, timedelta
from models import ChallengeInstance


class PoolManager:
    """Manages dynamic challenge container creation"""
    
    def __init__(self):
        self.network_name = 'cyberforge_cyberforge-network'
        print("🔧 PoolManager initialized")
    
    CHALLENGE_CONFIG = {
        1: {'image': 'cyberforge-challenge-1', 'name_prefix': 'cyberforge-ch1-dynamic', 'port_range': (30000, 30099)},
        2: {'image': 'cyberforge-challenge-2', 'name_prefix': 'cyberforge-ch2-dynamic', 'port_range': (30100, 30199)},
        3: {'image': 'cyberforge-challenge-3', 'name_prefix': 'cyberforge-ch3-dynamic', 'port_range': (30200, 30299)},
    }
    
    def find_free_port(self, challenge_id, db_session):
        """Find available port"""
        if challenge_id not in self.CHALLENGE_CONFIG:
            return None
        start_port, end_port = self.CHALLENGE_CONFIG[challenge_id]['port_range']
        assigned = db_session.query(ChallengeInstance).filter_by(
            challenge_id=challenge_id, 
            status='running'
        ).all()
        assigned_ports = {inst.port for inst in assigned}
        for port in range(start_port, end_port):
            if port not in assigned_ports:
                return port
        return None
    
    def assign_container(self, challenge_id, user_id, db_session):
        """Create dynamic container"""
        print(f"🔧 assign_container: challenge={challenge_id}, user={user_id}")
        
        existing = db_session.query(ChallengeInstance).filter_by(
            user_id=user_id,
            challenge_id=challenge_id,
            status='running'
        ).first()
        
        if existing:
            print(f"✅ Existing container: {existing.container_name}")
            return existing
        
        if challenge_id not in self.CHALLENGE_CONFIG:
            print(f"❌ Challenge {challenge_id} not in config")
            return None
        
        config = self.CHALLENGE_CONFIG[challenge_id]
        port = self.find_free_port(challenge_id, db_session)
        
        if not port:
            print("❌ No free ports")
            return None
        
        container_name = f"{config['name_prefix']}-user{user_id}-{port}"
        
        try:
            cmd = [
                'docker', 'run', '-d',
                '--name', container_name,
                '--network', self.network_name,
                '-p', f'{port}:22',
                '--rm',
                config['image']
            ]
            
            print(f"🚀 Running: {' '.join(cmd)}")
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
            
            if result.returncode != 0:
                print(f"❌ Docker error: {result.stderr}")
                return None
            
            container_id = result.stdout.strip()
            print(f"✅ Container created: {container_name}")
            
            instance = ChallengeInstance(
                user_id=user_id,
                challenge_id=challenge_id,
                container_name=container_name,
                port=port,
                status='running',
                expires_at=datetime.utcnow() + timedelta(hours=2)
            )
            
            db_session.add(instance)
            db_session.commit()
            
            return instance
            
        except Exception as e:
            print(f"❌ Exception: {e}")
            return None
    
    def release_container(self, container_name):
        """Stop container"""
        try:
            result = subprocess.run(
                ['docker', 'stop', container_name],
                capture_output=True,
                text=True,
                timeout=10
            )
            return result.returncode == 0
        except Exception as e:
            print(f"❌ Release error: {e}")
            return False


# CRITICAL: Export singleton instance
pool_manager = PoolManager()
