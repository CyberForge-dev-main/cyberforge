# ============================================================
# ДОБАВИТЬ В backend/models.py В КОНЕЦ ФАЙЛА
# ============================================================

class ChallengeInstance(db.Model):
    """
    Назначение челленджа пользователю
    (управление доступом к статическим контейнерам)
    """
    __tablename__ = 'challenge_instances'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    challenge_id = db.Column(db.Integer, db.ForeignKey('challenges.id'), nullable=False)
    assigned_port = db.Column(db.Integer, nullable=False)
    container_name = db.Column(db.String(128), nullable=False)
    status = db.Column(db.String(32), default='active', nullable=False)  # active/released
    assigned_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    released_at = db.Column(db.DateTime)
    
    # Relationships
    user = db.relationship('User', backref='challenge_instances')
    challenge = db.relationship('Challenge', backref='instances')
    
    def to_dict(self):
        """Сериализация"""
        return {
            'id': self.id,
            'user_id': self.user_id,
            'challenge_id': self.challenge_id,
            'assigned_port': self.assigned_port,
            'container_name': self.container_name,
            'status': self.status,
            'assigned_at': self.assigned_at.isoformat() if self.assigned_at else None,
            'released_at': self.released_at.isoformat() if self.released_at else None
        }
