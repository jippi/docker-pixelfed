#!/bin/bash

set -o errexit -o nounset -o pipefail

echo "==> Copying .env file"
cp -v .env.docker .env

echo "==> Changing .env permissions"
chmod -v 0777 .env

app_domain="localhost"

# We disable dottie validation since 'localhost' as APP_DOMAIN
# is *technically* a misconfiguration

echo "==> Reconfiguring .env file for testing"
scripts/dottie set --no-validate \
    ENTRYPOINT_SKIP_SCRIPTS="02-check-config.sh" \
    APP_DOMAIN="${app_domain}" \
    APP_NAME="docker-pixelfed e2e" \
    DB_PASSWORD="helloworld" \
    DOCKER_APP_TAG="${DOCKER_APP_TAG:?missing}" \
    DOCKER_PROXY_ACME_PROFILE="disabled" \
    DOCKER_PROXY_LETSENCRYPT_TEST="disabled" \
    DOCKER_PROXY_PROFILE="disabled" \
    ENFORCE_EMAIL_VERIFICATION="false" \
    INSTANCE_CONTACT_EMAIL="github@example.com" \
    OAUTH_ENABLED="true"

echo "==> Starting Pixelfed containers"
docker compose up -d --no-build --quiet-pull

echo "==> Starting npm dependencies"
npm ci

echo "==> Install playwright depdendencies"
npx playwright install chromium --with-deps

echo "==> Wait for the site to come up, while streaming the logs"
curl --retry-delay 1 --retry 120 --retry-max-time 120 --retry-all-errors --fail -o /dev/null "http://${app_domain}:8080"

echo "==> Run playwright tests"
export E2E_URL="http://${app_domain}:8080"
exec npx playwright test --config images/pixelfed/playwright.config.ts
