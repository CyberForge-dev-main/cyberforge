# CyberForge Verification Scripts

Скрипты для проверки проекта CyberForge

## Быстрый старт

    ./quick_check.sh
    ./verify_all.sh
    ./verify_all.sh > report.txt 2>&1

## Скрипты

verify_all.sh - полная проверка всего проекта
verify_backend.sh - Backend API и база данных
verify_docker.sh - Docker контейнеры и порты
verify_ssh.sh - SSH челленджи
verify_database.sh - SQLite база данных
quick_check.sh - быстрая проверка

## Что проверяется

- Окружение (Docker, Python, curl)
- Структура файлов
- Docker Compose конфигурация
- Запущенные контейнеры
- Доступность портов
- Backend API endpoints
- SSH челленджи
- База данных SQLite
- Git репозиторий

## Использование

Отдельные проверки:

    ./verify_backend.sh
    ./verify_docker.sh
    ./verify_ssh.sh

Только ошибки:

    ./verify_all.sh 2>&1 | grep FAIL

Сохранить отчёт:

    ./verify_all.sh > report.txt 2>&1
