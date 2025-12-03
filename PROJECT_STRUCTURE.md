# CyberForge Project Structure (High-Level)

- backend/ — Flask API, SQLite, бизнес-логика, JWT.
- frontend/ (или website/) — статика/HTML, nginx.
- challenges/ — Dockerfile'ы и файлы для SSH-челленджей (ch1–ch3).
- tests/ — скрипты тестов (health_check, user_flow_full, test_rate_limit).
- artifacts/ — автоматически собираемые артефакты при падении тестов.
- logs/ — журналы действий ИИ и скриптов (новое).
- session_logs/ — человеческие логи сессий (по желанию).
- docker-compose.yml — оркестрация всего стека.
- Makefile — удобные команды (up/down/test/logs/health).
- test.sh — мастер-скрипт, прогоняющий все проверки.
- 4 ключевых протокольных файла:
  - CYBERFORGE_MASTER_PROMPT_v4.md
  - CYBERFORGE_KNOWLEDGE_BASE_v4.md
  - CYBERFORGE_WORKING_PROTOCOLS_v4.md
  - QUICK_START_AI_v4.md
