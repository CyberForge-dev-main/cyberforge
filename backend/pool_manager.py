from datetime import datetime, timedelta
from models import ChallengeInstance

class PoolManager:
    """Manages challenge container pool assignments"""
    
    # Challenge pool configuration
    POOL_CONFIG = {
        1: {'name_prefix': 'cyberforge-ch1-pool', 'ports': list(range(30000, 30005))},
        2: {'name_prefix': 'cyberforge-ch2-pool', 'ports': list(range(30010, 30015))},
        3: {'name_prefix': 'cyberforge-ch3-pool', 'ports': list(range(30020, 30025))},
    }
    
    @staticmethod
    def get_available_container(challenge_id: int, db_session):
        """Find available container from pool"""
        if challenge_id not in PoolManager.POOL_CONFIG:
            return None
        
        config = PoolManager.POOL_CONFIG[challenge_id]
        
        # Get all assigned ports for this challenge
        assigned = db_session.query(ChallengeInstance).filter_by(
            challenge_id=challenge_id,
            status='active'
        ).all()
        
        assigned_ports = {inst.port for inst in assigned}
        
        # Find first available port
        for port in config['ports']:
            if port not in assigned_ports:
                container_name = f"{config['name_prefix']}-{port}"
                return {
                    'name': container_name,
                    'port': port,
                    'challenge_id': challenge_id
                }
        
        return None
    
    @staticmethod
    def assign_container(user_id: int, challenge_id: int, db_session):
        """Assign container to user"""
        # Check if user already has active instance
        existing = db_session.query(ChallengeInstance).filter_by(
            user_id=user_id,
            challenge_id=challenge_id,
            status='active'
        ).first()
        
        if existing:
            return existing
        
        # Find available container
        container = PoolManager.get_available_container(challenge_id, db_session)
        if not container:
            return None
        
        # Create instance
        instance = ChallengeInstance(
            user_id=user_id,
            challenge_id=challenge_id,
            port=container['port'],
            container_name=container['name'],
            status='active',
            created_at=datetime.utcnow(),
            expires_at=datetime.utcnow() + timedelta(hours=2)
        )
        
        db_session.add(instance)
        db_session.commit()
        
        return instance
    
    @staticmethod
    def release_container(instance_id: int, db_session) -> bool:
        """Release container"""
        instance = db_session.query(ChallengeInstance).filter_by(id=instance_id).first()
        if not instance:
            return False
        
        instance.status = 'released'
        db_session.commit()
        return True
    
    @staticmethod
    def cleanup_expired(db_session):
        """Cleanup expired instances"""
        expired = db_session.query(ChallengeInstance).filter(
            ChallengeInstance.expires_at < datetime.utcnow(),
            ChallengeInstance.status == 'active'
        ).all()
        
        for instance in expired:
            instance.status = 'expired'
        
        db_session.commit()
        return len(expired)

# Export singleton
pool_manager = PoolManager()
