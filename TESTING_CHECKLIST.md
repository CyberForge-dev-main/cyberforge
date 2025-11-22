# CyberForge Testing Checklist ✅

## Tier 1: Basic Connectivity
- [ ] Docker контейнеры все UP (6 штук)
- [ ] Website отвечает на localhost:3000
- [ ] Backend отвечает на localhost:5000
- [ ] Juice Shop отвечает на localhost:3001
- [ ] SSH port 2222 открыт
- [ ] SSH port 2223 открыт
- [ ] SSH port 2224 открыт

## Tier 2: Website Functionality
- [ ] Главная страница загружается
- [ ] Challenge 1 кнопка кликается
- [ ] Challenge 2 кнопка кликается
- [ ] Challenge 3 кнопка кликается
- [ ] Juice Shop кнопка кликается

## Tier 3: SSH Challenges
- [ ] SSH CH1: `ssh ctfuser@localhost -p 2222` с паролем password123
- [ ] SSH CH2: `ssh ctfuser@localhost -p 2223` с паролем password123
- [ ] SSH CH3: `ssh ctfuser@localhost -p 2224` с паролем password123
- [ ] CH1: можно выполнить `pwd`, `ls`, `cat`
- [ ] CH1: флаг находится и читается

## Tier 4: Juice Shop
- [ ] http://localhost:3001 загружается
- [ ] Админ панель найдена (F12 → Network)
- [ ] Можно войти без пароля (SQLi)
- [ ] Страница продуктов видна
- [ ] Корзина работает

## Tier 5: Network (WiFi)
- [ ] Website доступен с другого устройства на 192.168.0.114:3000
- [ ] SSH с другого устройства на 192.168.0.114:2222
- [ ] Juice Shop с другого устройства на 192.168.0.114:3001

## Tier 6: Git & Documentation
- [ ] git log показывает все 3 Phase коммита
- [ ] README.md актуален
- [ ] docker-compose.yml работает
- [ ] .env файл правильный
