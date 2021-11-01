#!/bin/bash
set -e

TESTCAFE_TESTS_FOLDER="$(pwd)/end-to-end"

# Start the backend that serves the media files to be migrated
# Listens internally on port 80 (addressed as http://<assets_container>/assets/)
startMigrationAssetsContainer

# 'Admin' tests
docker run --rm --env-file=$(pwd)/.env --network gateway --env-file "${ENV_FILE}" -v "${TESTCAFE_TESTS_FOLDER}":/tests testcafe/testcafe --screenshots path=/tests/reports/screenshots,takeOnFails=true chromium /tests/tests/admin/**/*.spec.js --assertion-timeout 30000
# Add UI test data
docker run --env-file=$(pwd)/.env --rm --network gateway --env-file "${ENV_FILE}" -v "${TESTCAFE_TESTS_FOLDER}":/tests testcafe/testcafe --screenshots path=/tests/reports/screenshots,takeOnFails=true chromium /tests/tests/ui/data-migrations.js --assertion-timeout 30000
# 'UI' tests
docker run --env-file=$(pwd)/.env --rm --network gateway --env-file "${ENV_FILE}" -v "${TESTCAFE_TESTS_FOLDER}":/tests testcafe/testcafe --screenshots path=/tests/reports/screenshots,takeOnFails=true chromium /tests/tests/ui/*.spec.js --assertion-timeout 30000
