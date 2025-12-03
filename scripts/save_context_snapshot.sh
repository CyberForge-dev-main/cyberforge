#!/bin/bash
# Append compact context snapshot after test run

LOG_FILE="./logs/context_history.log"
mkdir -p "$(dirname "$LOG_FILE")"

{
  echo "========================================"
  echo "TIMESTAMP: $(date -Iseconds)"
  echo "PWD: $(pwd)"
  echo ""
  echo "GIT:"
  git branch --show-current 2>/dev/null || echo "no-branch"
  git log --oneline -1 2>/dev/null || echo "no-commits"
  git status --short 2>/dev/null || echo "no-status"
  echo ""
  echo "DOCKER:"
  docker-compose ps 2>/dev/null || echo "docker-compose ps failed"
  echo ""
  echo "LAST_TEST_SUMMARY (tail -10):"
  # Ожидаем, что ./test.sh уже вывел своё, но на всякий случай сохраним последний прогон явно
  if [ -f ./last_test_output.log ]; then
    tail -10 ./last_test_output.log
  else
    echo "no last_test_output.log"
  fi
  echo ""
} >> "$LOG_FILE"
