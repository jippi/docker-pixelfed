#!/bin/bash
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

# Wait for the database to be available
await-database-ready

# Ensure locks directory is around for flock usage later
ensure-directory-exists "${docker_locks_path}"

# Following https://docs.pixelfed.org/running-pixelfed/installation/#one-time-setup-tasks
#
# NOTE: Caches happens in [30-cache.sh]
#
# NOTE: we use 'nonblock' here to ensure any commands waiting (due to lockfile) exit 1 immidately
#       so we don't double-run "only-once" commands. Docker Compose will restart the container on failure

only-once "key:generate" run-as-runtime-user \
    flock --exclusive --nonblock "${docker_locks_path}/11-first-time-setup@key-generate.lock" \
    php artisan key:generate

only-once "storage:link" run-as-runtime-user \
    flock --exclusive --nonblock "${docker_locks_path}/11-first-time-setup@storage:link.lock" \
    php artisan storage:link

only-once "initial:migrate" run-as-runtime-user \
    flock --exclusive --nonblock "${docker_locks_path}/11-first-time-setup@initial:migrate.lock" \
    php artisan migrate --force

only-once "import:cities" run-as-runtime-user \
    flock --exclusive --nonblock "${docker_locks_path}/11-first-time-setup@import:cities.lock" \
    php artisan import:cities

if is-true "${ACTIVITY_PUB:-false}"; then
    only-once "instance:actor" run-as-runtime-user \
        flock --exclusive --nonblock "${docker_locks_path}/11-first-time-setup@instance:actor.lock" \
        php artisan instance:actor
fi

if is-true "${OAUTH_ENABLED:-false}"; then
    only-once "passport:keys" run-as-runtime-user \
        flock --exclusive --nonblock "${docker_locks_path}/11-first-time-setup@passport:keys.lock" \
        php artisan passport:keys
fi
