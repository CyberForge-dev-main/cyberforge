PROJECT_NAME=cyberforge

.PHONY: up down restart logs ps test health

up:
	docker compose up -d

down:
	docker compose down

restart: down up

logs:
	docker compose logs --tail=100 -f

ps:
	docker compose ps

test:
	@echo "Running system tests..."
	@./tests/health_check.sh
	@./tests/test_rate_limit.sh
	@./tests/user_flow_full.sh

health:
	@./check_system.sh
