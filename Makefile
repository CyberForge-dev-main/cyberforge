PROJECT_NAME=cyberforge

up:
	docker-compose up -d

down:
	docker-compose down -v

restart: down up

logs:
	docker-compose logs --tail=200 -f

ps:
	docker-compose ps

test:
	./test.sh

health:
	./tests/health_check.sh
