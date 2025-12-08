from flask import Flask, jsonify, request
from flask_cors import CORS
from flask_jwt_extended import JWTManager, jwt_required, get_jwt_identity
from config import Config
from models import db, User, Challenge, Submission, ChallengeInstance
from auth import register_user, authenticate_user, get_current_user
from time import time

RATE_LIMIT_WINDOW = 60
RATE_LIMIT_MAX = 5
rate_buckets = {}

def is_rate_limited(user_id: int, challenge_id: int) -> bool:
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

app = Flask(__name__)
app.config.from_object(Config)
db.init_app(app)
jwt = JWTManager(app)
CORS(app, origins=["*"], supports_credentials=True)

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
    user, token = authenticate_user(data['username'], data['password'])
    if not user:
        return jsonify({"error": token}), 401
    return jsonify({
        "message": "Login successful",
        "token": token,
        "user": {"id": user.id, "username": user.username}
    }), 200

@limiter.limit("5 per minute")
@app.route('/api/submit_flag', methods=['POST'])
@jwt_required()
def submit_flag():
    user = get_current_user()
    data = request.get_json()
    if not data or not data.get('challenge_id') or not data.get('flag'):
        return jsonify({"error": "Missing fields"}), 400
    
    challenge_id = data['challenge_id']
    challenge = db.session.get(Challenge, challenge_id)
    if not challenge:
        return jsonify({"error": "Challenge not found"}), 404
    
    # Check if already solved
    existing = Submission.query.filter_by(
        user_id=user.id,
        challenge_id=challenge_id,
        is_correct=True
    ).first()
    if existing:
        return jsonify({
            "error": "Challenge already solved",
            "solve_time": existing.solve_time,
            "points": 0
        }), 400
    
    # Rate limit
    if is_rate_limited(user.id, challenge_id):
        return jsonify({
            "success": False,
            "message": "Too many attempts. Please try again later."
        }), 429
    
    # Check flag
    is_correct = (data['flag'] == challenge.flag)
    solve_time = None
    if is_correct:
        from datetime import datetime
        time_diff = datetime.utcnow() - user.created_at
        solve_time = int(time_diff.total_seconds())
    
    submission = Submission(
        user_id=user.id,
        challenge_id=challenge.id,
        submitted_flag=data['flag'],
        is_correct=is_correct,
        solve_time=solve_time
    )
    db.session.add(submission)
    db.session.commit()
    
    return jsonify({
        "success": is_correct,
        "message": "Correct flag!" if is_correct else "Wrong flag",
        "points": challenge.points if is_correct else 0,
        "solve_time": solve_time
    }), 200

@app.route('/api/challenges', methods=['GET'])
def get_challenges():
    challenges = Challenge.query.all()
    return jsonify([{
        "id": c.id,
        "name": c.name,
        "description": c.description,
        "points": c.points,
        "port": c.port,
        "category": c.category,
        "difficulty": c.difficulty
    } for c in challenges]), 200

@app.route('/api/leaderboard', methods=['GET'])
def get_leaderboard():
    users = User.query.all()
    result = []
    for user in users:
        correct = Submission.query.filter_by(user_id=user.id, is_correct=True).all()
        points = sum(db.session.get(Challenge, s.challenge_id).points for s in correct if db.session.get(Challenge, s.challenge_id))
        result.append({"username": user.username, "solved": len(correct), "points": points})
    return jsonify(sorted(result, key=lambda x: x['points'], reverse=True)), 200

@app.route('/api/user/progress', methods=['GET'])
@jwt_required()
def user_progress():
    user = get_current_user()
    submissions = Submission.query.filter_by(user_id=user.id, is_correct=True).all()
    solved_ids = [s.challenge_id for s in submissions]
    return jsonify({
        "username": user.username,
        "challenges_solved": len(submissions),
        "total_points": sum(s.challenge.points for s in submissions),
        "solved_ids": solved_ids
    }), 200

@app.route('/api/user/<username>/profile', methods=['GET'])
def get_user_profile(username):
    user = User.query.filter_by(username=username).first()
    if not user:
        return jsonify({"error": "User not found"}), 404
    
    correct_submissions = Submission.query.filter_by(user_id=user.id, is_correct=True).all()
    total_points = sum(s.challenge.points for s in correct_submissions)
    
    by_category = {}
    for submission in correct_submissions:
        category = submission.challenge.category
        if category not in by_category:
            by_category[category] = {"solved": 0, "points": 0}
        by_category[category]["solved"] += 1
        by_category[category]["points"] += submission.challenge.points
    
    favorite_category = None
    if by_category:
        favorite_category = max(by_category.items(), key=lambda x: x[1]["solved"])[0]
    
    users = User.query.all()
    leaderboard = []
    for u in users:
        correct = Submission.query.filter_by(user_id=u.id, is_correct=True).all()
        points = sum(db.session.get(Challenge, s.challenge_id).points for s in correct if db.session.get(Challenge, s.challenge_id))
        leaderboard.append({"username": u.username, "points": points})
    leaderboard = sorted(leaderboard, key=lambda x: x['points'], reverse=True)
    rank = next((i+1 for i, u in enumerate(leaderboard) if u['username'] == username), None)
    
    recent = Submission.query.filter_by(user_id=user.id, is_correct=True).order_by(Submission.submitted_at.desc()).limit(5).all()
    recent_activity = [{
        "challenge_name": s.challenge.name,
        "challenge_id": s.challenge_id,
        "points": s.challenge.points,
        "submitted_at": s.submitted_at.isoformat(),
        "solve_time": s.solve_time
    } for s in recent]
    
    return jsonify({
        "username": user.username,
        "email": user.email,
        "created_at": user.created_at.isoformat(),
        "total_points": total_points,
        "challenges_solved": len(correct_submissions),
        "rank": rank,
        "by_category": by_category,
        "favorite_category": favorite_category,
        "recent_activity": recent_activity
    }), 200

# ============================================================
# CHALLENGE POOL ENDPOINTS
# ============================================================

@app.route('/api/challenge/assign/<int:challenge_id>', methods=['POST'])
@jwt_required()
def assign_challenge(challenge_id):
    """Assign challenge container to user"""
    from pool_manager import pool_manager
    
    user_id = get_jwt_identity()
    challenge = db.session.get(Challenge, challenge_id)
    
    if not challenge:
        return jsonify({'error': 'Challenge not found'}), 404
    
    instance = pool_manager.assign_container(challenge_id, user_id, db.session)
    
    if not instance:
        return jsonify({'error': 'No available containers'}), 503
    
    return jsonify({
        'success': True,
        'instance': {
            'id': instance.id,
            'container_name': instance.container_name,
            'port': instance.port,
            'ssh_command': f'ssh ctfuser@localhost -p {instance.port}',
            'expires_at': instance.expires_at.isoformat()
        }
    }), 201

@app.route('/api/challenge/release/<int:instance_id>', methods=['POST'])
@jwt_required()
def release_challenge(instance_id):
    """Release challenge container"""
    from pool_manager import pool_manager
    
    user_id = get_jwt_identity()
    instance = db.session.get(ChallengeInstance, instance_id)
    
    if not instance:
        return jsonify({'error': 'Instance not found'}), 404
    
    if instance.user_id != user_id:
        return jsonify({'error': 'Not your instance'}), 403
    
    success = pool_manager.release_container(instance.container_name)
    
    if success:
        instance.status = 'stopped'
        db.session.commit()
    
    return jsonify({'success': success}), 200 if success else 500


@app.route('/api/challenge/my-instances', methods=['GET'])
@jwt_required()
def get_my_instances():
    """Get user's active containers"""
    user_id = get_jwt_identity()
    instances = ChallengeInstance.query.filter_by(
        user_id=user_id,
        status='running'
    ).all()
    
    return jsonify({
        'instances': [
            {
                'id': inst.id,
                'challenge_id': inst.challenge_id,
                'container_name': inst.container_name,
                'port': inst.port,
                'ssh_command': f'ssh ctfuser@localhost -p {inst.port}',
                'created_at': inst.created_at.isoformat(),
                'expires_at': inst.expires_at.isoformat()
            }
            for inst in instances
        ]
    }), 200


# ============================================================
# APPLICATION ENTRY POINT
# ============================================================

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
        print("✅ Database tables created/verified")
    
    print("🚀 Starting Flask server on 0.0.0.0:5000")
    print("="*50)
    app.run(host='0.0.0.0', port=5000, debug=True)
