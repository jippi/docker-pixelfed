#!/bin/bash

set -o errexit -o nounset -o pipefail

echo "==> Copying .env file"
cp -v .env.docker .env

echo "==> Changing .env permissions"
chmod -v 0777 .env

echo "==> Starting ngrok"
docker run --quiet --detach --name ngrok --env NGROK_AUTHTOKEN --net=host ngrok/ngrok http 8080

echo "==> Following ngrok logs"
docker logs ngrok -f &

echo "==> Finding ngrok tunnel public URL"
domain="$(curl --retry-all-errors --fail --retry 60 --retry-max-time 60 http://127.0.0.1:4040/api/tunnels | jq -r ".tunnels[0].public_url")"
echo "OK: ${domain}"

echo "==> Finding ngrok tunnel public host (domain without https://)"
app_domain=${domain#https://*}
echo "OK: ${app_domain}"

echo "==> Reconfiguring .env file for testing"
scripts/dottie set \
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
curl --header "ngrok-skip-browser-warning: true" --retry-delay 1 --retry 60 --retry-max-time 60 --retry-all-errors --fail -o /dev/null "${domain}"

echo "==> Run playwright tests"
export E2E_URL="${domain}"
exec npx playwright test --config images/pixelfed/playwright.config.ts
