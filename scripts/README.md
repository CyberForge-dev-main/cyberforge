# CyberForge Scripts

Utility scripts for testing, diagnostics, and maintenance.

## Testing Scripts

### `smoke_test.sh`
**Full smoke test** - проверяет всю систему после изменений.

```bash
./scripts/smoke_test.sh
```

**Тесты:**
- Infrastructure (backend, website, juice-shop, SSH ports)
- API endpoints (register, login, challenges, submit_flag, leaderboard)
- SSH challenges (флаги через SSH)

**Выход:**
- `0` - все тесты прошли
- `1` - есть failed тесты

---

### `health_check.sh`
**Quick health check** - быстрая проверка состояния.

```bash
./scripts/health_check.sh
```

**Проверяет:**
- Docker контейнеры
- Доступность портов
- HTTP endpoints

---

### `test_rate_limit.sh`
**Rate limit test** - проверка защиты от брутфорса.

```bash
./scripts/test_rate_limit.sh
```

**Ожидаемый результат:**
- 5 попыток проходят (200/400)
- 6-я попытка отклоняется (429 Too Many Requests)

---

### `user_flow_full.sh`
**End-to-end user flow** - полный цикл работы пользователя.

```bash
./scripts/user_flow_full.sh
```

**Шаги:**
1. Регистрация
2. Логин
3. Получение челленджей
4. Отправка флага
5. Проверка leaderboard
6. Проверка progress

---

## Diagnostic Scripts

### `check_system.sh`
**Full system check** - детальная диагностика.

```bash
./scripts/check_system.sh
```

**Показывает:**
- Docker контейнеры (статус)
- Backend health
- Git статус
- API smoke test (login, challenges, submit, leaderboard)
- SSH ch1 flag test

---

### `dump_system.sh`
**Project dump** - создаёт полный дамп структуры проекта.

```bash
./scripts/dump_system.sh
```

**Создаёт файл:** `project_dump.txt`

**Содержит:**
- Directory tree
- File contents (все текстовые файлы)

**Игнорирует:**
- `.git/`, `node_modules/`, `__pycache__/`
- Бинарники, архивы, изображения

---

## Usage with Makefile

```bash
make test     # Запустить все тесты
make smoke    # Smoke test
make health   # Health check
make dump     # Создать project dump
```

---

## CI/CD Integration

Эти скрипты используются в GitHub Actions:

- `.github/workflows/test.yml` - запускает `smoke_test.sh`
- `.github/workflows/lint.yml` - проверяет shell скрипты (shellcheck)

---

## Dependencies

**Требуются для тестов:**
- `curl` - HTTP запросы
- `jq` - JSON парсинг
- `sshpass` - SSH без интерактивного ввода пароля
- `nc` (netcat) - проверка портов

**Установка (Ubuntu/Debian):**
```bash
sudo apt-get install -y curl jq sshpass netcat
```
