from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash

db = SQLAlchemy()

class User(db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(256), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    submissions = db.relationship('Submission', backref='user', lazy=True, cascade='all, delete-orphan')
    challenge_instances = db.relationship('ChallengeInstance', backref='user', lazy=True, cascade='all, delete-orphan')
    
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

class Challenge(db.Model):
    __tablename__ = 'challenges'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text, nullable=False)
    category = db.Column(db.String(50), nullable=False)
    difficulty = db.Column(db.String(20), nullable=False)
    points = db.Column(db.Integer, default=100)
    flag = db.Column(db.String(200), nullable=False)
    port = db.Column(db.Integer, nullable=True)
    
    submissions = db.relationship('Submission', backref='challenge', lazy=True, cascade='all, delete-orphan')
    challenge_instances = db.relationship('ChallengeInstance', backref='challenge', lazy=True, cascade='all, delete-orphan')

class Submission(db.Model):
    __tablename__ = 'submissions'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    challenge_id = db.Column(db.Integer, db.ForeignKey('challenges.id'), nullable=False)
    submitted_flag = db.Column(db.String(200), nullable=False)
    is_correct = db.Column(db.Boolean, default=False)
    submitted_at = db.Column(db.DateTime, default=datetime.utcnow)
    solve_time = db.Column(db.Integer, nullable=True)
    
    __table_args__ = (
        db.Index('idx_user_challenge', 'user_id', 'challenge_id'),
        db.Index('idx_submitted_at', 'submitted_at'),
    )

class ChallengeInstance(db.Model):
    __tablename__ = 'challenge_instances'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    challenge_id = db.Column(db.Integer, db.ForeignKey('challenges.id'), nullable=False)
    container_name = db.Column(db.String(100), unique=True, nullable=False)
    port = db.Column(db.Integer, nullable=False)
    status = db.Column(db.String(20), default='running')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    expires_at = db.Column(db.DateTime, nullable=False)
    
    __table_args__ = (
        db.Index('idx_user_challenge_inst', 'user_id', 'challenge_id'),
        db.Index('idx_status', 'status'),
        db.Index('idx_expires_at', 'expires_at'),
    )
    
    def to_dict(self):
        return {
            'id': self.id,
            'challenge_id': self.challenge_id,
            'challenge_name': self.challenge.name if self.challenge else None,
            'container_name': self.container_name,
            'port': self.port,
            'status': self.status,
            'created_at': self.created_at.isoformat(),
            'expires_at': self.expires_at.isoformat()
        }
