
#!/bin/bash

# CyberForge: Автоматизация Git Push
# Использование: bash git_push.sh "сообщение коммита"
# Пример: bash git_push.sh "Add testing script"

set -e

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   CyberForge: Автоматизация Git Push               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}\n"

# ==========================================
# ШАГ 1: Проверка аргумента
# ==========================================

if [ -z "$1" ]; then
    echo -e "${RED}✗ ОШИБКА: нужно указать сообщение коммита${NC}"
    echo "Использование: bash git_push.sh \"сообщение коммита\""
    echo "Пример: bash git_push.sh \"Add testing script\""
    exit 1
fi

COMMIT_MSG="$1"

echo -e "${YELLOW}Сообщение коммита: \"$COMMIT_MSG\"${NC}\n"

# ==========================================
# ШАГ 2: Проверка Git установки
# ==========================================

echo -e "${YELLOW}▶ Проверка Git...${NC}"

if ! command -v git &> /dev/null; then
    echo -e "${RED}✗ Git не установлен${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Git установлен${NC}\n"

# ==========================================
# ШАГ 3: Проверка в репо
# ==========================================

echo -e "${YELLOW}▶ Проверка репозитория...${NC}"

if [ ! -d ".git" ]; then
    echo -e "${RED}✗ Это не Git репозиторий${NC}"
    echo "Перейди в папку cyberforge и повтори"
    exit 1
fi

REPO_NAME=$(git config --get remote.origin.url | sed 's/.*\///' | sed 's/.git//')
echo -e "${GREEN}✓ Репозиторий: $REPO_NAME${NC}\n"

# ==========================================
# ШАГ 4: Проверка изменений
# ==========================================

echo -e "${YELLOW}▶ Проверка изменений...${NC}"

GIT_STATUS=$(git status --porcelain)

if [ -z "$GIT_STATUS" ]; then
    echo -e "${YELLOW}⚠ Нет изменений для коммита${NC}"
    exit 0
fi

echo -e "${GREEN}✓ Найдены изменения:${NC}"
echo "$GIT_STATUS" | sed 's/^/  /'
echo ""

# ==========================================
# ШАГ 5: Git Add
# ==========================================

echo -e "${YELLOW}▶ Добавление файлов (git add)...${NC}"

git add -A

echo -e "${GREEN}✓ Файлы добавлены${NC}\n"

# ==========================================
# ШАГ 6: Git Commit
# ==========================================

echo -e "${YELLOW}▶ Создание коммита...${NC}"

git commit -m "$COMMIT_MSG"

echo -e "${GREEN}✓ Коммит создан${NC}\n"

# ==========================================
# ШАГ 7: Настройка Git Credentials
# ==========================================

echo -e "${YELLOW}▶ Настройка Git credentials helper...${NC}"

git config --global credential.helper 'cache --timeout=3600'

echo -e "${GREEN}✓ Git будет запомнить пароль на 1 час${NC}\n"

# ==========================================
# ШАГ 8: Git Push
# ==========================================

echo -e "${YELLOW}▶ Загрузка на GitHub (git push)...${NC}"
echo -e "${YELLOW}  Внимание: может потребоваться ввести токен${NC}\n"

if git push -u origin main; then
    echo -e "\n${GREEN}✓ Git push успешно завершён${NC}"
else
    echo -e "\n${RED}✗ Git push не удался${NC}"
    echo -e "${YELLOW}Советы:${NC}"
    echo "  1. Убедись, что у тебя есть Personal Access Token на GitHub"
    echo "  2. Используй токен вместо пароля"
    echo "  3. Токен должен иметь права: repo, write:packages"
    echo ""
    exit 1
fi

echo ""

# ==========================================
# ИТОГОВЫЙ ОТЧЁТ
# ==========================================

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              УСПЕХ! ✓                             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}\n"

echo -e "${GREEN}✓ Коммит загружен на GitHub${NC}"
echo -e "${GREEN}✓ Ссылка на репозиторий:${NC}"
echo "  https://github.com/$(git config user.name)/$REPO_NAME"
echo ""
echo -e "${YELLOW}Что дальше:${NC}"
echo "  1. Проверь на GitHub: https://github.com/CyberForge-dev-main/cyberforge"
echo "  2. Увидишь новые файлы в репозитории"
echo "  3. История коммитов обновлена"
echo ""
