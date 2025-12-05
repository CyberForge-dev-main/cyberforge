from flask import Flask, jsonify, request
from flask_cors import CORS
from flask_jwt_extended import JWTManager, jwt_required
from config import Config
from models import db, User, Challenge, Submission
from auth import register_user, authenticate_user, get_current_user

from time import time

RATE_LIMIT_WINDOW = 60
RATE_LIMIT_MAX = 5
_rate_buckets = {}

def is_rate_limited(user_id: int) -> bool:
    now = time()
    bucket = _rate_buckets.get(user_id, [])
    bucket = [t for t in bucket if now - t < RATE_LIMIT_WINDOW]
    if len(bucket) >= RATE_LIMIT_MAX:
        _rate_buckets[user_id] = bucket
        return True
    bucket.append(now)
    _rate_buckets[user_id] = bucket
    return False

app = Flask(__name__)
app.config.from_object(Config)

db.init_app(app)
jwt = JWTManager(app)
CORS(app)

@app.route('/api/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'OK', 'message': 'Backend is running'}), 200

@app.route('/api/register', methods=['POST'])
def register():
    data = request.get_json()
    if not data or not data.get('username') or not data.get('password'):
        return jsonify({'error': 'Missing required fields'}), 400
    username = data['username']
    email = data.get('email', f"{username}@example.local")
    password = data['password']
    user, error = register_user(username=username, email=email, password=password)
    if error:
        return jsonify({'error': error}), 400
    return jsonify({
        'message': 'User registered successfully',
        'user': {'id': user.id, 'username': user.username, 'email': user.email}
    }), 201

@app.route('/api/login', methods=['POST'])
def login():
    data = request.get_json()
    if not data or not data.get('username') or not data.get('password'):
        return jsonify({'error': 'Missing credentials'}), 400
    user, token = authenticate_user(data['username'], data['password'])
    if not user:
        return jsonify({'error': token}), 401
    return jsonify({
        'message': 'Login successful',
        'access_token': token,
        'user': {'id': user.id, 'username': user.username}
    }), 200

@app.route('/api/submit_flag', methods=['POST'])
@jwt_required()
def submit_flag():
    user = get_current_user()
    if is_rate_limited(user.id):
        return jsonify({'success': False, 'message': 'Too many attempts. Please try again later.'}), 429
    data = request.get_json()
    if not data or not data.get('challenge_id') or not data.get('flag'):
        return jsonify({'error': 'Missing fields'}), 400
    challenge = Challenge.query.get(data['challenge_id'])
    if not challenge:
        return jsonify({'error': 'Challenge not found'}), 404
    existing = Submission.query.filter_by(user_id=user.id, challenge_id=challenge.id, is_correct=True).first()
    if existing:
        return jsonify({'success': False, 'message': 'Already solved!', 'points': 0}), 200
    is_correct = data['flag'].strip() == challenge.flag.strip()
    submission = Submission(user_id=user.id, challenge_id=challenge.id, submitted_flag=data['flag'], is_correct=is_correct)
    db.session.add(submission)
    db.session.commit()
    return jsonify({
        'success': is_correct,
        'message': 'Correct flag!' if is_correct else 'Wrong flag',
        'points': challenge.points if is_correct else 0
    }), 200

@app.route('/api/challenges', methods=['GET'])
def get_challenges():
    challenges = Challenge.query.all()
    return jsonify([{
        'id': c.id, 'name': c.name, 'description': c.description,
        'points': c.points, 'port': c.port, 'category': c.category,
        'difficulty': c.difficulty
    } for c in challenges]), 200

@app.route('/api/leaderboard', methods=['GET'])
@jwt_required()
def get_leaderboard():
    users = User.query.all()
    result = []
    for user in users:
        correct = Submission.query.filter_by(user_id=user.id, is_correct=True).all()
        points = sum(Challenge.query.get(s.challenge_id).points for s in correct if Challenge.query.get(s.challenge_id))
        result.append({"username": user.username, "solved": len(correct), "points": points})
    return jsonify(sorted(result, key=lambda x: x["points"], reverse=True)), 200

@app.route('/api/user/progress', methods=['GET'])
@jwt_required()
def user_progress():
    user = get_current_user()
    submissions = Submission.query.filter_by(user_id=user.id, is_correct=True).all()
    solved_ids = [s.challenge_id for s in submissions]
    return jsonify({
        'username': user.username,
        'challenges_solved': len(submissions),
        'total_points': sum(s.challenge.points for s in submissions),
        'solved_ids': solved_ids
    }), 200

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Internal server error'}), 500

def init_db():
    with app.app_context():
        db.create_all()
        if Challenge.query.count() == 0:
            challenges = [
                Challenge(name='SSH Basics', description='Connect via SSH and find the flag', 
                         flag='flag{welcome_to_cyberforge_1}', points=100, port=2222,
                         category='SSH', difficulty='Easy'),
                Challenge(name='Hidden Files', description='Find the hidden flag file', 
                         flag='flag{linux_basics_are_fun}', points=100, port=2223,
                         category='SSH', difficulty='Easy'),
                Challenge(name='Directory Search', description='Search directories for the flag', 
                         flag='flag{find_and_conquer}', points=100, port=2224,
                         category='SSH', difficulty='Medium'),
                Challenge(name='Juice Shop: Admin Login', description='Login as admin in OWASP Juice Shop (port 3001). Flag format: flag{admin_email}',
                         flag='flag{admin@juice-sh.op}', points=150, port=3001,
                         category='Web', difficulty='Easy'),
                Challenge(name='Juice Shop: SQL Injection', description='Bypass login using SQL injection. Flag: flag{sqli_success}',
                         flag='flag{sqli_success}', points=200, port=3001,
                         category='Web', difficulty='Medium'),
                Challenge(name='Juice Shop: XSS', description='Perform XSS attack. Flag: flag{xss_executed}',
                         flag='flag{xss_executed}', points=200, port=3001,
                         category='Web', difficulty='Medium'),
            ]
            for challenge in challenges:
                db.session.add(challenge)
            db.session.commit()

if __name__ == '__main__':
    init_db()
    app.run(debug=True, host='0.0.0.0', port=5000)
