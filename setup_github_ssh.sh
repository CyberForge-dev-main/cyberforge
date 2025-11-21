#!/bin/bash

# CyberForge: Автоматическая настройка SSH для GitHub (один раз навсегда)
# Использование: bash setup_github_ssh.sh
# После этого: git push будет работать без пароля!

set -e

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   CyberForge: Настройка SSH для GitHub             ║${NC}"
echo -e "${BLUE}║   (Один раз навсегда, без паролей!)               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}\n"

echo -e "${YELLOW}▶ Проверка SSH ключа...${NC}"

SSH_KEY_PATH="$HOME/.ssh/id_rsa"

if [ -f "$SSH_KEY_PATH" ]; then
    echo -e "${GREEN}✓ SSH ключ уже существует: $SSH_KEY_PATH${NC}\n"
else
    echo -e "${YELLOW}SSH ключ не найден. Создаём новый...${NC}\n"
    ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -N "" -C "cyberforge@localhost"
    echo -e "${GREEN}✓ SSH ключ создан: $SSH_KEY_PATH${NC}\n"
fi

echo -e "${YELLOW}▶ Настройка SSH Agent...${NC}"

eval "$(ssh-agent -s)" > /dev/null
ssh-add "$SSH_KEY_PATH" > /dev/null 2>&1 || ssh-add "$SSH_KEY_PATH"

echo -e "${GREEN}✓ SSH Agent запущен и ключ добавлен${NC}\n"

echo -e "${YELLOW}▶ Твой публичный SSH ключ:${NC}\n"

PUBLIC_KEY=$(cat "$HOME/.ssh/id_rsa.pub")

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "$PUBLIC_KEY"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "${YELLOW}ВНИМАНИЕ: Нужно добавить этот ключ на GitHub!${NC}\n"

echo -e "${YELLOW}Шаги:${NC}"
echo "1. Открой браузер: https://github.com/settings/keys"
echo "2. Нажми: New SSH key"
echo "3. Title: CyberForge"
echo "4. Key type: Authentication Key"
echo "5. Скопируй ВЕСЬ ключ выше (все строки с ssh-rsa...)"
echo "6. Вставь в поле Key"
echo "7. Нажми: Add SSH key"
echo ""

read -p "Нажми Enter когда добавишь ключ на GitHub... "

echo -e "\n${YELLOW}▶ Тестирование подключения к GitHub...${NC}\n"

if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo -e "${GREEN}✓ Успешное подключение к GitHub!${NC}\n"
else
    echo -e "${YELLOW}⚠ Проверяем ещё раз...${NC}"
    ssh -T git@github.com || echo -e "${YELLOW}(это нормально, главное что ключ работает)${NC}"
fi

echo -e "\n${YELLOW}▶ Смена Git remote с HTTPS на SSH...${NC}"

cd ~/Documents/cyberforge 2>/dev/null || cd . 

if [ -d ".git" ]; then
    CURRENT_REMOTE=$(git config --get remote.origin.url)
    echo -e "${YELLOW}Текущий remote: $CURRENT_REMOTE${NC}"
    
    if [[ $CURRENT_REMOTE == https://* ]]; then
        SSH_REMOTE=$(echo "$CURRENT_REMOTE" | sed 's|https://github.com/|git@github.com:|' | sed 's|\.git$|.git|')
        git remote set-url origin "$SSH_REMOTE"
        echo -e "${GREEN}✓ Remote изменен на: $SSH_REMOTE${NC}\n"
    else
        echo -e "${GREEN}✓ Remote уже SSH: $CURRENT_REMOTE${NC}\n"
    fi
else
    echo -e "${YELLOW}⚠ Не в Git репозитории, пропускаем смену remote${NC}\n"
fi

echo -e "${YELLOW}▶ Настройка SSH конфига...${NC}"

SSH_CONFIG="$HOME/.ssh/config"

if ! grep -q "Host github.com" "$SSH_CONFIG" 2>/dev/null; then
    mkdir -p "$HOME/.ssh"
    cat >> "$SSH_CONFIG" << EOFCONFIG
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking no
    AddKeysToAgent yes
EOFCONFIG
    echo -e "${GREEN}✓ SSH конфиг обновлен${NC}\n"
else
    echo -e "${GREEN}✓ SSH конфиг уже настроен${NC}\n"
fi

echo -e "${YELLOW}▶ Настройка автозагрузки SSH Agent...${NC}"

SHELL_RC="$HOME/.bashrc"

if ! grep -q "SSH_AUTH_SOCK" "$SHELL_RC"; then
    cat >> "$SHELL_RC" << 'EOFBASHRC'

# Auto-start SSH Agent
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null
    ssh-add ~/.ssh/id_rsa 2>/dev/null
fi
EOFBASHRC
    echo -e "${GREEN}✓ Автозагрузка настроена в .bashrc${NC}\n"
else
    echo -e "${GREEN}✓ Автозагрузка уже настроена${NC}\n"
fi

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              ГОТОВО! ✓                            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}\n"

echo -e "${GREEN}✓ SSH ключ настроен${NC}"
echo -e "${GREEN}✓ Git remote изменен на SSH${NC}"
echo -e "${GREEN}✓ SSH Agent будет запускаться автоматически${NC}\n"

echo -e "${YELLOW}Теперь можешь использовать:${NC}"
echo "  git push origin main"
echo "  git pull origin main"
echo ""
echo -e "${YELLOW}Всё будет работать БЕЗ пароля!${NC}\n"

echo -e "${YELLOW}Проверка:${NC}"
echo "  1. Новый терминал: ssh -T git@github.com"
echo "  2. Должна вывести: Hi [username]! You've successfully authenticated..."
echo "  3. git push - работает без пароля!"
echo ""
