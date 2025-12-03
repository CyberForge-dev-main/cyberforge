#!/bin/bash
set -e

# Запускаем основной тестовый скрипт и логируем вывод
./test.sh | tee last_test_output.log
TEST_EXIT=$?

# Сохраняем контекст (git, docker, хвост тестов)
./scripts/save_context_snapshot.sh || echo "WARN: context snapshot failed"

exit $TEST_EXIT
