#!/usr/bin/env python3
"""Database initialization script"""

from app import app, db
from models import User, Challenge, ChallengeInstance, Submission

def init_database():
    """Initialize database with tables and seed data"""
    with app.app_context():
        print("🔧 Dropping all tables...")
        db.drop_all()
        
        print("🔧 Creating all tables...")
        db.create_all()
        
        print("🔧 Seeding challenges...")
        challenges = [
            Challenge(
                id=1,
                name="SSH Basics",
                category="SSH",
                description="Find the flag in the home directory",
                difficulty="Easy",
                points=100,
                flag="flag{welcome_to_ssh}",
                port=2222
            ),
            Challenge(
                id=2,
                name="Hidden Files",
                category="SSH",
                description="Find the hidden flag file",
                difficulty="Easy",
                points=100,
                flag="flag{hidden_files_found}",
                port=2223
            ),
            Challenge(
                id=3,
                name="Directory Search",
                category="SSH",
                description="Search directories for the flag",
                difficulty="Medium",
                points=100,
                flag="flag{directory_master}",
                port=2224
            ),
            Challenge(
                id=4,
                name="Juice Shop: Admin Access",
                category="Web",
                description="Login as admin in Juice Shop. Submit admin email as flag format: flag{admin_email}",
                difficulty="Easy",
                points=150,
                flag="flag{admin@juice-sh.op}",
                port=3001
            ),
            Challenge(
                id=5,
                name="Juice Shop: SQL Injection",
                category="Web",
                description="Bypass login using SQL injection in Juice Shop",
                difficulty="Medium",
                points=200,
                flag="flag{sql_injection_master}",
                port=3001
            ),
            Challenge(
                id=6,
                name="Juice Shop: XSS",
                category="Web",
                description="Execute XSS attack in Juice Shop",
                difficulty="Medium",
                points=200,
                flag="flag{xss_executed}",
                port=3001
            )
        ]
        
        for challenge in challenges:
            existing = Challenge.query.filter_by(id=challenge.id).first()
            if not existing:
                db.session.add(challenge)
        
        db.session.commit()
        
        print("✅ Database initialized successfully!")
        print(f"   - Tables: {len(db.Model.metadata.tables)} created")
        print(f"   - Challenges: {Challenge.query.count()} seeded")
        
if __name__ == '__main__':
    init_database()
