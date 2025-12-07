#!/usr/bin/env python3
"""
Challenge Pool Manager
Управление назначением статических контейнеров пользователям
"""

from typing import Optional, Dict, List
from models import ChallengeInstance, Challenge
from datetime import datetime

# Конфигурация pool
CHALLENGE_POOLS = {
    1: {  # Challenge 1
        'containers': [
            {'name': 'cyberforge-ch1-pool-1', 'port': 30000},
            {'name': 'cyberforge-ch1-pool-2', 'port': 30001},
            {'name': 'cyberforge-ch1-pool-3', 'port': 30002},
            {'name': 'cyberforge-ch1-pool-4', 'port': 30003},
            {'name': 'cyberforge-ch1-pool-5', 'port': 30004},
        ]
    },
    2: {  # Challenge 2
        'containers': [
            {'name': 'cyberforge-ch2-pool-1', 'port': 30010},
            {'name': 'cyberforge-ch2-pool-2', 'port': 30011},
            {'name': 'cyberforge-ch2-pool-3', 'port': 30012},
            {'name': 'cyberforge-ch2-pool-4', 'port': 30013},
            {'name': 'cyberforge-ch2-pool-5', 'port': 30014},
        ]
    },
    3: {  # Challenge 3
        'containers': [
            {'name': 'cyberforge-ch3-pool-1', 'port': 30020},
            {'name': 'cyberforge-ch3-pool-2', 'port': 30021},
            {'name': 'cyberforge-ch3-pool-3', 'port': 30022},
            {'name': 'cyberforge-ch3-pool-4', 'port': 30023},
            {'name': 'cyberforge-ch3-pool-5', 'port': 30024},
        ]
    }
}


class PoolManager:
    """Менеджер pool контейнеров"""
    
    @staticmethod
    def get_available_container(challenge_id: int, db_session) -> Optional[Dict]:
        """
        Получить свободный контейнер для челленджа
        
        Args:
            challenge_id: ID челленджа
            db_session: сессия БД
            
        Returns:
            Dict с полями name, port или None если нет свободных
        """
        if challenge_id not in CHALLENGE_POOLS:
            return None
        
        pool = CHALLENGE_POOLS[challenge_id]['containers']
        
        # Получить занятые порты
        assigned = ChallengeInstance.query.filter_by(
            challenge_id=challenge_id,
            status='active'
        ).all()
        
        assigned_ports = {inst.assigned_port for inst in assigned}
        
        # Найти свободный контейнер
        for container in pool:
            if container['port'] not in assigned_ports:
                return container
        
        return None
    
    @staticmethod
    def assign_container(user_id: int, challenge_id: int, db_session) -> Optional[ChallengeInstance]:
        """
        Назначить контейнер пользователю
        
        Args:
            user_id: ID пользователя
            challenge_id: ID челленджа
            db_session: сессия БД
            
        Returns:
            ChallengeInstance или None если нет свободных
        """
        # Проверить, нет ли уже назначенного
        existing = ChallengeInstance.query.filter_by(
            user_id=user_id,
            challenge_id=challenge_id,
            status='active'
        ).first()
        
        if existing:
            return existing
        
        # Найти свободный контейнер
        container = PoolManager.get_available_container(challenge_id, db_session)
        if not container:
            return None
        
        # Создать instance
        instance = ChallengeInstance(
            user_id=user_id,
            challenge_id=challenge_id,
            assigned_port=container['port'],
            container_name=container['name'],
            status='active'
        )
        
        db_session.add(instance)
        db_session.commit()
        
        return instance
    
    @staticmethod
    def release_container(instance_id: int, db_session) -> bool:
        """
        Освободить контейнер
        
        Args:
            instance_id: ID экземпляра
            db_session: сессия БД
            
        Returns:
            bool: успешно ли освобождён
        """
        instance = ChallengeInstance.query.get(instance_id)
        if not instance:
            return False
        
        instance.status = 'released'
        instance.released_at = datetime.utcnow()
        db_session.commit()
        
        return True
    
    @staticmethod
    def get_pool_stats(challenge_id: int, db_session) -> Dict:
        """
        Получить статистику pool
        
        Args:
            challenge_id: ID челленджа
            db_session: сессия БД
            
        Returns:
            Dict со статистикой
        """
        if challenge_id not in CHALLENGE_POOLS:
            return {'error': 'Challenge not found'}
        
        pool_size = len(CHALLENGE_POOLS[challenge_id]['containers'])
        
        assigned = ChallengeInstance.query.filter_by(
            challenge_id=challenge_id,
            status='active'
        ).count()
        
        return {
            'challenge_id': challenge_id,
            'pool_size': pool_size,
            'assigned': assigned,
            'available': pool_size - assigned
        }


# Глобальный экземпляр
pool_manager = PoolManager()
