#!/bin/bash

set -o errexit -o nounset -o pipefail

# copy .env file
cp -v .env.docker .env

# fix .env permissions
chmod -v 0777 .env

# start ngrok
docker run --quiet --detach --name ngrok --env NGROK_AUTHTOKEN --net=host ngrok/ngrok http 8080

# find ngrok domain
domain="$(curl --retry-all-errors --fail --retry 60 --retry-max-time 60 http://127.0.0.1:4040/api/tunnels | jq -r ".tunnels[0].public_url")"
echo "domain=${domain}"

# remove https:// prefix for APP_DOMAIN
app_domain=${domain#https://*}
echo "app_domain=${domain}"

# configure .env file
scripts/dottie set \
    APP_DOMAIN="${app_domain}" \
    APP_NAME="docker-pixelfed e2e" \
    DB_PASSWORD="helloworld" \
    DOCKER_APP_PHP_VERSION="${DOCKER_APP_PHP_VERSION:?missing}" \
    DOCKER_APP_RELEASE="${DOCKER_APP_RELEASE:?missing}" \
    DOCKER_APP_RUNTIME="${DOCKER_APP_RUNTIME:?missing}" \
    DOCKER_PROXY_ACME_PROFILE="disabled" \
    DOCKER_PROXY_LETSENCRYPT_TEST="disabled" \
    DOCKER_PROXY_PROFILE="disabled" \
    ENFORCE_EMAIL_VERIFICATION="false" \
    INSTANCE_CONTACT_EMAIL="github@example.com" \
    OAUTH_ENABLED="true"

# Start Pixelfed containers in the background
docker compose up -d --no-build

# Install npm dependencies
npm ci

# Install playwright depdendencies
npx playwright install chromium --with-deps

# Wait for the site to come up, while streaming the logs
curl --header "ngrok-skip-browser-warning: true" --retry-delay 1 --retry 120 --retry-all-errors --fail -o /dev/null "${domain}"

# Run playwright tests
export E2E_URL="${domain}"
exec npx playwright test --config images/pixelfed/playwright.config.ts
