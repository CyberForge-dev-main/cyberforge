from models import db, User
from flask_jwt_extended import create_access_token
from sqlalchemy.exc import IntegrityError

def register_user(username, email, password):
    """Register a new user. Returns (user, error)"""
    if User.query.filter_by(username=username).first():
        return None, "Username already exists"
    
    if email and User.query.filter_by(email=email).first():
        return None, "Email already exists"
    
    user = User(username=username, email=email)
    user.set_password(password)
    
    try:
        db.session.add(user)
        db.session.commit()
        return user, None
    except IntegrityError:
        db.session.rollback()
        return None, "Registration failed"
    except Exception:
        db.session.rollback()
        return None, "Registration failed"

def authenticate_user(username, password):
    """Authenticate user. Returns (token, error)"""
    user = User.query.filter_by(username=username).first()
    if not user or not user.check_password(password):
        return None, "Invalid credentials"
    
    access_token = create_access_token(identity=str(user.id))
    return access_token, None  # ← ИСПРАВЛЕНО: возвращает (token, error)

def get_current_user():
    """Get current authenticated user"""
    from flask_jwt_extended import get_jwt_identity
    user_id = int(get_jwt_identity())
    return User.query.get(user_id)
