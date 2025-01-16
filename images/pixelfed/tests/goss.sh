#!/bin/bash

set -o errexit -o nounset -o pipefail

for tag in ${TAGS:?missing}; do
    dgoss run \
        -v "./.env.testing:/var/www/.env" \
        -e "EXPECTED_PHP_VERSION=${DOCKER_APP_PHP_VERSION:?missing}" \
        -e "PHP_BASE_TYPE=${PHP_BASE_TYPE?:missing}" \
        -e ENTRYPOINT_SKIP_SCRIPTS="02-check-config.sh,11-first-time-setup.sh,12-migrations.sh" \
        "$tag"
done
