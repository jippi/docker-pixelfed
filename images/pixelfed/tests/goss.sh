#!/bin/bash

for tag in ${TAGS:?missing}; do
    dgoss run \
        -v "./.env.testing:/var/www/.env" \
        -e "EXPECTED_PHP_VERSION=${DOCKER_APP_PHP_VERSION:?missing}" \
        -e "PHP_BASE_TYPE=${PHP_BASE_TYPE?:missing}" \
        "$tag"
done
