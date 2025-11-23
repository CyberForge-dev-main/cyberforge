# 🛡️ CyberForge

**Self-Hosted Cybersecurity Training Platform on Docker**

> Интерактивная платформа для практического обучения кибербезопасности в изолированной Docker среде

---

## 📋 Быстрый старт (5 минут)

```bash
# 1. Клонировать репозиторий
git clone https://github.com/CyberForge-dev-main/cyberforge.git
cd cyberforge

# 2. Запустить контейнеры
docker compose up -d

# 3. Подождать инициализации
sleep 45

# 4. Проверить статус
docker compose ps

# 5. Открыть в браузере
# Website: http://localhost:3000
# API: http://localhost:8000/api/status
```

---

## ✨ Основные возможности

- ✅ **Flask REST API Backend** на порту 8000
- ✅ **Node.js Web Dashboard** на порту 3000
- ✅ **3 Ubuntu контейнера** для challenges (ch1, ch2, ch3)
- ✅ **Docker Compose** оркестрация
- ✅ **Безопасный sandbox** для практического обучения
- ✅ **Полностью функциональный** MVP
- ✅ **Готов к production** для локального использования

---

## 🏗️ Архитектура

### 5 Docker контейнеров

| Контейнер | Тип | Порт | Назначение |
|-----------|-----|------|-----------|
| **backend** | Flask API | 8000 | REST API endpoints |
| **website** | Node.js | 3000 | Web Dashboard |
| **ch1** | Ubuntu | docker | SSH Challenge 1 |
| **ch2** | Ubuntu | docker | SSH Challenge 2 |
| **ch3** | Ubuntu | docker | SSH Challenge 3 |

### Сетевая архитектура

```
┌─────────────────────────────────────────┐
│         Docker Network: main            │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────┐  ┌──────────┐             │
│  │ Backend  │  │ Website  │             │
│  │ Flask    │  │ Node.js  │             │
│  │ :8000    │  │ :3000    │             │
│  └──────────┘  └──────────┘             │
│                                         │
│  ┌──────┐ ┌──────┐ ┌──────┐            │
│  │ Ch1  │ │ Ch2  │ │ Ch3  │            │
│  │Ubuntu│ │Ubuntu│ │Ubuntu│            │
│  │ :22  │ │ :22  │ │ :22  │            │
│  └──────┘ └──────┘ └──────┘            │
│                                         │
└─────────────────────────────────────────┘
```

---

## 📝 Структура проекта

```
cyberforge/
├── docker-compose.yml       # Конфигурация всех сервисов
├── README.md                # Этот файл
├── backend/
│   ├── Dockerfile           # Docker образ backend
│   ├── app.py              # Flask приложение
│   ├── requirements.txt     # Python зависимости
│   └── .dockerignore
├── website/
│   ├── Dockerfile          # Docker образ website
│   ├── package.json        # Node.js зависимости
│   ├── app.js              # Express приложение
│   └── .dockerignore
└── challenges/
    ├── ch1/
    ├── ch2/
    └── ch3/
```

---

## 🚀 Использование

### Проверить здоровье сервисов

```bash
# Backend status
curl http://localhost:8000/api/status

# Website status
curl http://localhost:3000/api/status
```

### Просмотр логов

```bash
# Все логи в real-time
docker compose logs -f

# Логи конкретного сервиса
docker logs cyberforge-backend -f
docker logs cyberforge-website -f
```

### Войти в challenge контейнер

```bash
# SSH access через docker exec
docker exec -it cyberforge-ch1 bash
docker exec -it cyberforge-ch2 bash
docker exec -it cyberforge-ch3 bash

# Пользователь: ctfuser
# Пароль: ctfpass
```

### Управление контейнерами

```bash
# Остановить все
docker compose down

# Полная очистка
docker compose down -v
docker system prune -af --volumes

# Перезагрузить все
docker compose restart

# Пересобрать образы
docker compose build --no-cache
```

---

## 📦 Системные требования

| Требование | Минимум | Рекомендуется |
|-----------|---------|---------------|
| **RAM** | 4 GB | 8 GB |
| **Disk** | 5 GB | 10 GB |
| **CPU** | 2 cores | 4 cores |
| **OS** | Linux/macOS/Windows (WSL2) | Linux |

### Установка Docker

**Linux:**
```bash
sudo apt install docker.io docker-compose
sudo usermod -aG docker $USER
```

**macOS:**
```bash
brew install docker
```

**Windows:**
Скачать [Docker Desktop](https://www.docker.com/products/docker-desktop)

---

## 🔄 Фазы разработки

### ✅ Phase 1-4 (Завершено - текущее состояние)

- ✓ Docker Compose оркестрация
- ✓ Flask Backend API
- ✓ Node.js Website
- ✓ 3 Challenge контейнера
- ✓ Основная документация
- ✓ Production ready for local use

### 🚧 Phase 5 (В разработке)

- [ ] JWT Authentication
- [ ] User Progress Tracking
- [ ] SQLite Database
- [ ] Flag Validation System

### 📋 Phase 6 (Планируется)

- [ ] User Dashboard
- [ ] Leaderboard System
- [ ] Hint System
- [ ] Admin Panel

### 🔮 Phase 7+ (Будущее)

- [ ] Mobile App (React Native)
- [ ] Advanced Challenge Types
- [ ] Team Competitions
- [ ] Custom Challenge Creator

---

## 🐛 Решение проблем

### Ошибка: Port 8000 is already in use

```bash
# Найти и убить процесс
lsof -i :8000
kill -9 <PID>

# Или изменить порт в docker-compose.yml
# "8000:8000" → "9000:8000"
```

### Ошибка: Permission denied

```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Контейнеры не запускаются

```bash
# Полная очистка и перезапуск
docker compose down -v
docker system prune -af --volumes
docker compose build --no-cache
docker compose up -d
```

### Out of memory

Docker Desktop → Settings → Resources → Memory (установить 6-8 GB)

---

## 📚 Команды управления

```bash
# Построение
docker compose build              # Построить образы
docker compose build --no-cache   # Перестроить без кеша

# Запуск
docker compose up -d              # Запустить в фоне
docker compose start              # Запустить (если stopped)

# Остановка
docker compose stop               # Остановить (не удалять)
docker compose down               # Остановить и удалить
docker compose down -v            # Остановить, удалить + volumes

# Информация
docker compose ps                 # Статус контейнеров
docker compose logs               # Просмотр логов
docker compose logs -f            # Real-time логи
docker compose restart            # Перезагрузить все

# Работа с контейнерами
docker exec -it cyberforge-backend bash
docker exec -it cyberforge-website bash
docker exec -it cyberforge-ch1 bash

# Очистка
docker system prune               # Удалить неиспользуемые образы
docker system prune -a            # Удалить все неиспользуемые
docker volume prune               # Удалить неиспользуемые volumes
```

---

## 🤝 Разработка и вклад

### Git workflow

```bash
# 1. Fork репозитория

# 2. Клонировать
git clone https://github.com/<your-username>/cyberforge.git
cd cyberforge

# 3. Создать ветку
git checkout -b feature/new-feature

# 4. Запустить для разработки
docker compose up -d

# 5. Внести изменения

# 6. Пересобрать образы
docker compose build --no-cache
docker compose up -d

# 7. Commit и push
git add .
git commit -m "Feature: Описание изменений"
git push origin feature/new-feature

# 8. Создать Pull Request
```

### Перед commit

```bash
# Проверить логи
docker compose logs

# Проверить статус
docker compose ps

# Проверить API
curl http://localhost:8000/api/status
curl http://localhost:3000/api/status
```

---

## 🔒 Безопасность

### Текущее состояние (MVP)

- ⚠️ Нет аутентификации
- ⚠️ Нет шифрования
- ⚠️ Debug режим отключен
- ⚠️ CORS включен (для разработки)

### Рекомендации

- НЕ использовать в production без дополнительной безопасности
- Использовать только в закрытой сети или localhost
- Регулярно обновлять зависимости

### Будущие улучшения (Phase 5+)

- [ ] JWT токены
- [ ] HTTPS/TLS
- [ ] Rate limiting
- [ ] Input validation
- [ ] CSRF protection

---

## 📝 Лицензия

**MIT License**

Используйте свободно в образовательных целях.
Указывайте авторство при использовании в своих проектах.

---

## 📞 Контакты и поддержка

- **GitHub:** https://github.com/CyberForge-dev-main/cyberforge
- **Issues:** https://github.com/CyberForge-dev-main/cyberforge/issues
- **Discussions:** https://github.com/CyberForge-dev-main/cyberforge/discussions

---

## 📊 Информация о проекте

| Информация | Значение |
|-----------|----------|
| **Версия** | 1.0 MVP |
| **Статус** | Production Ready (Local) |
| **Лицензия** | MIT |
| **Язык** | Python (Backend), JavaScript (Frontend) |
| **Платформа** | Docker & Docker Compose |
| **Обновлено** | 23 Ноября 2025 |

---

## 🎯 Что дальше?

1. **Запустить:** `docker compose up -d`
2. **Открыть:** http://localhost:3000
3. **Изучить:** challenges в ch1, ch2, ch3 контейнерах
4. **Развивать:** contribute на GitHub

**Спасибо за использование CyberForge! 🚀**