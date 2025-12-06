PROJECT_NAME=cyberforge

.PHONY: up down restart logs ps test health dump

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
	@echo "Running integration tests..."
	@./scripts/health_check.sh
	@./scripts/test_rate_limit.sh
	@./scripts/user_flow_full.sh

smoke:
	@echo "Running smoke test..."
	@./scripts/smoke_test.sh

health:
	@./scripts/check_system.sh

dump:
	@./scripts/dump_system.sh
