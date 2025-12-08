from flask import Flask, jsonify, request
from flask_cors import CORS
from flask_jwt_extended import JWTManager, jwt_required, get_jwt_identity
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
import redis
from config import Config
from models import db, User, Challenge, Submission, ChallengeInstance
from auth import register_user, authenticate_user, get_current_user
from time import time
import os

app = Flask(__name__)
app.config.from_object(Config)

# Database
db.init_app(app)

# JWT
jwt = JWTManager(app)

# CORS
CORS(app, origins=["*"], supports_credentials=True)

# Redis (с fallback на in-memory)
REDIS_URL = os.getenv('REDIS_URL', 'redis://redis:6379/0')
try:
    redis_client = redis.from_url(REDIS_URL, decode_responses=True)
    redis_client.ping()
    storage_uri = REDIS_URL
    print(f"✅ Redis connected: {REDIS_URL}")
except Exception as e:
    storage_uri = "memory://"
    print(f"⚠️  Redis unavailable, using in-memory storage: {e}")

# Rate Limiter
limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    storage_uri=storage_uri,
    default_limits=["200 per day", "50 per hour"],
    storage_options={"socket_connect_timeout": 30},
    strategy="fixed-window"
)

# Legacy rate limiting (для обратной совместимости)
RATE_LIMIT_WINDOW = 60
RATE_LIMIT_MAX = 5
rate_buckets = {}

def is_rate_limited(user_id: int, challenge_id: int) -> bool:
    """Legacy rate limiting function (kept for compatibility)"""
    key = f"{user_id}:{challenge_id}"
    now = time()
    bucket = rate_buckets.get(key, [])
    bucket = [t for t in bucket if now - t < RATE_LIMIT_WINDOW]
    if len(bucket) >= RATE_LIMIT_MAX:
        rate_buckets[key] = bucket
        return True
    bucket.append(now)
    rate_buckets[key] = bucket
    return False

# ======================
# ENDPOINTS
# ======================

@app.route('/api/health', methods=['GET'])
def health_check():
    return jsonify({"status": "OK", "message": "Backend is running"}), 200

@app.route('/api/register', methods=['POST'])
def register():
    data = request.get_json()
    if not data or not data.get('username') or not data.get('password'):
        return jsonify({"error": "Missing required fields"}), 400
    username = data['username']
    email = data.get('email', f"{username}@example.local")
    password = data['password']
    user, error = register_user(username=username, email=email, password=password)
    if error:
        return jsonify({"error": error}), 400
    return jsonify({
        "message": "User registered successfully",
        "user": {"id": user.id, "username": user.username, "email": user.email}
    }), 201

@app.route('/api/login', methods=['POST'])
def login():
    data = request.get_json()
    if not data or not data.get('username') or not data.get('password'):
        return jsonify({"error": "Missing credentials"}), 400
    token, error = authenticate_user(data['username'], data['password'])
    if error:
        return jsonify({"error": error}), 401
    return jsonify({"access_token": token}), 200

@app.route('/api/challenges', methods=['GET'])
@jwt_required()
def get_challenges():
    challenges = Challenge.query.all()
    return jsonify([{
        "id": c.id,
        "name": c.name,
        "description": c.description,
        "category": c.category,
        "difficulty": c.difficulty,
        "points": c.points,
        "port": c.port
    } for c in challenges]), 200

@app.route('/api/submit_flag', methods=['POST'])
@jwt_required()
@limiter.limit("5 per minute")
def submit_flag():
    current_user_id = get_jwt_identity()
    data = request.get_json()
    if not data or 'challenge_id' not in data or 'flag' not in data:
        return jsonify({"error": "Missing challenge_id or flag"}), 400
    
    challenge_id = data['challenge_id']
    submitted_flag = data['flag']
    
    # Legacy rate limit check
    if is_rate_limited(current_user_id, challenge_id):
        return jsonify({"error": "Rate limit exceeded. Try again later."}), 429
    
    challenge = Challenge.query.get(challenge_id)
    if not challenge:
        return jsonify({"error": "Challenge not found"}), 404
    
    is_correct = (submitted_flag == challenge.flag)
    solve_time = None
    
    if is_correct:
        existing = Submission.query.filter_by(
            user_id=current_user_id, 
            challenge_id=challenge_id, 
            is_correct=True
        ).first()
        if existing:
            return jsonify({"error": "Already solved"}), 400
        
        user_obj = User.query.get(current_user_id)
        if user_obj:
            solve_time = int(time() - user_obj.created_at.timestamp())
    
    submission = Submission(
        user_id=current_user_id,
        challenge_id=challenge_id,
        submitted_flag=submitted_flag,
        is_correct=is_correct,
        solve_time=solve_time
    )
    db.session.add(submission)
    db.session.commit()
    
    return jsonify({
        "correct": is_correct,
        "message": "Correct flag!" if is_correct else "Incorrect flag",
        "points": challenge.points if is_correct else 0
    }), 200

@app.route('/api/leaderboard', methods=['GET'])
@jwt_required()
def leaderboard():
    results = db.session.query(
        User.username,
        db.func.sum(Challenge.points).label('total_points'),
        db.func.count(Submission.id).label('solves')
    ).join(Submission, Submission.user_id == User.id)\
     .join(Challenge, Challenge.id == Submission.challenge_id)\
     .filter(Submission.is_correct == True)\
     .group_by(User.id, User.username)\
     .order_by(db.desc('total_points'))\
     .all()
    
    leaderboard_data = [{
        "rank": idx + 1,
        "username": r.username,
        "score": r.total_points,
        "solves": r.solves
    } for idx, r in enumerate(results)]
    
    return jsonify(leaderboard_data), 200

@app.route('/api/user/progress', methods=['GET'])
@jwt_required()
def user_progress():
    current_user_id = get_jwt_identity()
    user = User.query.get(current_user_id)
    if not user:
        return jsonify({"error": "User not found"}), 404
    
    solved = db.session.query(Challenge).join(Submission)\
        .filter(Submission.user_id == current_user_id, Submission.is_correct == True).all()
    total = Challenge.query.count()
    points = sum(c.points for c in solved)
    
    return jsonify({
        "username": user.username,
        "solved": len(solved),
        "total": total,
        "points": points
    }), 200

@app.route('/api/user/<username>/profile', methods=['GET'])
@jwt_required()
def user_profile(username):
    user = User.query.filter_by(username=username).first()
    if not user:
        return jsonify({"error": "User not found"}), 404
    
    solved_challenges = db.session.query(Challenge).join(Submission)\
        .filter(Submission.user_id == user.id, Submission.is_correct == True).all()
    
    total_points = sum(c.points for c in solved_challenges)
    
    rank_query = db.session.query(
        User.id,
        db.func.sum(Challenge.points).label('total_points')
    ).join(Submission, Submission.user_id == User.id)\
     .join(Challenge, Challenge.id == Submission.challenge_id)\
     .filter(Submission.is_correct == True)\
     .group_by(User.id)\
     .order_by(db.desc('total_points'))\
     .all()
    
    rank = next((idx + 1 for idx, (uid, _) in enumerate(rank_query) if uid == user.id), None)
    
    return jsonify({
        "username": user.username,
        "email": user.email,
        "rank": rank,
        "total_points": total_points,
        "challenges_solved": len(solved_challenges),
        "solved_challenges": [{
            "id": c.id,
            "name": c.name,
            "category": c.category,
            "difficulty": c.difficulty,
            "points": c.points
        } for c in solved_challenges]
    }), 200

# ======================
# INITIALIZATION
# ======================

with app.app_context():
    db.create_all()
    print("✅ Database tables created/verified")

if __name__ == '__main__':
    print("🚀 Starting Flask server on 0.0.0.0:5000")
    print("=" * 50)
    app.run(host='0.0.0.0', port=5000, debug=True)
