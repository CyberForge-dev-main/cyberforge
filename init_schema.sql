-- CyberForge Database Schema

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(80) UNIQUE NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS challenges (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    category VARCHAR(50),
    difficulty VARCHAR(20),
    points INTEGER DEFAULT 100,
    flag VARCHAR(255) NOT NULL,
    port INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS submissions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    challenge_id INTEGER REFERENCES challenges(id) ON DELETE CASCADE,
    submitted_flag VARCHAR(255) NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE,
    solve_time INTEGER,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS challenge_instances (
    id SERIAL PRIMARY KEY,
    challenge_id INTEGER REFERENCES challenges(id) ON DELETE CASCADE,
    user_id INTEGER,
    container_name VARCHAR(255),
    port INTEGER,
    status VARCHAR(20) DEFAULT 'stopped',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP
);

-- Insert default challenges
INSERT INTO challenges (name, description, category, difficulty, points, flag, port)
VALUES 
    ('SSH Basics', 'Find the flag in the home directory', 'SSH', 'Easy', 100, 'flag{welcome_to_ssh}', 2222),
    ('Hidden Files', 'Find the hidden flag file', 'SSH', 'Easy', 100, 'flag{hidden_treasure}', 2223),
    ('Environment Variables', 'Check environment variables for the flag', 'SSH', 'Medium', 150, 'flag{env_secrets}', 2224),
    ('Juice Shop - XSS', 'Find and exploit XSS vulnerability', 'Web', 'Medium', 150, 'flag{xss_master}', 3001),
    ('Juice Shop - SQL Injection', 'Bypass authentication using SQL injection', 'Web', 'Hard', 200, 'flag{sql_ninja}', 3001)
ON CONFLICT DO NOTHING;
