from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from models import User, db

def register_user(username, email, password):
    """Регистрация нового пользователя"""
    if User.query.filter_by(username=username).first():
        return None, "Username already exists"
    
    user = User(username=username, email=email)
    user.set_password(password)
    
    db.session.add(user)
    db.session.commit()
    
    return user, None

def authenticate_user(username, password):
    """Авторизация пользователя"""
    user = User.query.filter_by(username=username).first()
    
    if not user or not user.check_password(password):
        return None, "Invalid credentials"
    
    access_token = create_access_token(identity=str(user.id))
    return user, access_token

def get_current_user():
    """Получить текущего пользователя из JWT токена"""
    user_id = int(get_jwt_identity())
    return User.query.get(user_id)
