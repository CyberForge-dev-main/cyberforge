# Backend Config Security

## CRITICAL RULE

SQLALCHEMY_DATABASE_URI = sqlite:///cyberforge.db

## FORBIDDEN

- os.environ.get DATABASE_URL
- postgresql://

## Recovery

cp backups/config.py.stable backend/config.py
docker compose restart backend
