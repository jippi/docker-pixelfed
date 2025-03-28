#!/bin/bash
# shellcheck disable=SC2119

: "${ENTRYPOINT_ROOT:="/docker"}"

# shellcheck source=SCRIPTDIR/../helpers.sh
source "${ENTRYPOINT_ROOT}/helpers.sh"

entrypoint-set-script-name "$0"

load-config-files

# Allow automatic applying of outstanding/new migrations on startup
: "${DOCKER_APP_RUN_ONE_TIME_SETUP_TASKS:=1}"

if is-false "${DOCKER_APP_RUN_ONE_TIME_SETUP_TASKS}"; then
    log-warning "Automatic run of the 'One-time setup tasks' is disabled."
    log-warning "Please set [DOCKER_APP_RUN_ONE_TIME_SETUP_TASKS=1] in your [.env] file to enable this."

    exit 0
fi

# Wait for the database to be ready
await-database-ready

# Make sure only one container run the remainder of this script at a time
acquire-lock

# Following https://docs.pixelfed.org/running-pixelfed/installation/#one-time-setup-tasks
#
# NOTE: Caches happens in [30-cache.sh]

only-once "key:generate" run-as-runtime-user php artisan key:generate
only-once "storage:link" run-as-runtime-user php artisan storage:link
only-once "initial:migrate" run-as-runtime-user php artisan migrate --force
only-once "import:cities" run-as-runtime-user php artisan import:cities

if is-true "${ACTIVITY_PUB:-false}"; then
    only-once "instance:actor" run-as-runtime-user php artisan instance:actor
fi

if is-true "${OAUTH_ENABLED:-false}"; then
    only-once "passport:keys" run-as-runtime-user php artisan passport:keys
fi

if is-true "${PF_LOGIN_WITH_MASTODON_ENABLED:-false}"; then
    only-once "passport:client::personal" run-as-runtime-user php artisan passport:client --personal --name "Created_By_Docker_11-first-time-setup.sh"
fi
