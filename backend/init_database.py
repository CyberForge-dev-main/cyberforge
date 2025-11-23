import sys
from app import app, db
from models import Challenge

def init_database():
    with app.app_context():
        print("Создание таблиц...")
        db.create_all()
        print("OK Таблицы созданы")
        
        if Challenge.query.first():
            print("WARN БД уже содержит данные")
            return
        
        challenges = [
            {'name': 'Web Challenge 1', 'category': 'web', 'points': 100,
             'description': 'Find hidden flag', 'flag': 'flag{web_1}'},
            {'name': 'SSH Challenge 1', 'category': 'ssh', 'points': 150,
             'description': 'SSH flag', 'flag': 'flag{ssh_1}'},
            {'name': 'Juice Shop', 'category': 'web', 'points': 200,
             'description': 'Find vulnerabilities', 'flag': 'flag{juice}'}
        ]
        
        for ch in challenges:
            db.session.add(Challenge(**ch))
            print("  + " + ch['name'])
        
        db.session.commit()
        print("OK Челленджей: " + str(Challenge.query.count()))

if __name__ == '__main__':
    try:
        init_database()
    except Exception as e:
        print("ERROR: " + str(e))
        sys.exit(1)
