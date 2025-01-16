#!/bin/bash

set -o errexit -o nounset -o pipefail

app_domain="localhost"

echo "==> Starting Pixelfed containers"
docker compose up -d --no-build --quiet-pull

echo "==> Starting npm dependencies"
npm ci

echo "==> Install playwright depdendencies"
npx playwright install chromium --with-deps

echo "==> Wait for the site to come up, while streaming the logs"
curl --retry-delay 1 --retry 180 --retry-max-time 180 --retry-all-errors --fail -o /dev/null "http://${app_domain}:8080"

echo "==> Run playwright tests"
export E2E_URL="http://${app_domain}:8080"
exec npx playwright test --config images/pixelfed/playwright.config.ts
