# 📚 CYBERFORGE KNOWLEDGE BASE

**Version:** 3.0 | Date: 2025-11-29

---

## 🏗️ АРХИТЕКТУРА

### ✅ Работает

```
SSH Challenges:
  ch1: 2222, flag{welcome_to_cyberforge_1}
  ch2: 2223, flag{linux_basics_are_fun}
  ch3: 2224, flag{find_and_conquer}

Docker: настроен, контейнеры запускаются
```

### ⚠️ Код есть, не тестировалось

```
Backend API (Flask:5000):
  GET  /api/health - ✅ РАБОТАЕТ
  GET  /api/challenges - ⚠️ КОД ЕСТЬ
  POST /api/register - ⚠️ КОД ЕСТЬ
  POST /api/login - ⚠️ КОД ЕСТЬ
  POST /api/submit-flag - ⚠️ КОД ЕСТЬ
  GET  /api/leaderboard - ⚠️ КОД ЕСТЬ
```

### ❓ Не проверено

```
- Frontend npm build
- Database содержимое
- End-to-end auth flow
```

---

## 🔗 ЗАВИСИМОСТИ

```
backend/app.py:
  ├─ models.py (User, Challenge, Submission)
  ├─ config.py (SQLite URI)
  ├─ auth.py (@token_required)
  └─ requirements.txt (Flask, SQLAlchemy, JWT)

docker-compose.yml:
  ├─ backend/Dockerfile
  ├─ challenges/ch{1,2,3}/Dockerfile
  └─ website/Dockerfile
```

---

## 🗄️ DATABASE

```sql
users: id, username, email, password_hash, created_at
challenges: id, name, description, flag, points, port
submissions: id, user_id, challenge_id, submitted_flag, is_correct
```

---

## 🚫 ANTI-PATTERNS

```
❌ Фразы: "MVP", "минимальная версия", "предполагаю"
❌ Действия: менять без MCP, удалять без backup, push без проверки
```

---

## 🔧 ТИПИЧНЫЕ ПРОБЛЕМЫ

**Backend не отвечает:**
```bash
docker compose logs backend
docker compose restart backend
```

**SSH не доступен:**
```bash
docker compose ps | grep challenge
docker compose restart
```

---

**Purpose:** База знаний с проверенными фактами