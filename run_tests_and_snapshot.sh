#!/bin/bash
./test.sh | tee last_test_output.log
TEST_EXIT=$?
./scripts/save_full_context.sh || echo "WARN: failed to save full context"
exit $TEST_EXIT
