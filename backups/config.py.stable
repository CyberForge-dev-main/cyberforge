import os

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret-key-change-in-production'
    
    # ИСПРАВЛЕНО: УБРАН os.environ.get('DATABASE_URL')
    # Хардкод SQLite URI (НЕТ POSTGRESQL)
    SQLALCHEMY_DATABASE_URI = 'sqlite:///cyberforge.db'
    
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY') or 'jwt-secret-key-change-in-production'
