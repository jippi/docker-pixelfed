#!/bin/bash
# shellcheck disable=SC2119

: "${ENTRYPOINT_ROOT:="/docker"}"

# shellcheck source=SCRIPTDIR/../helpers.sh
source "${ENTRYPOINT_ROOT}/helpers.sh"

entrypoint-set-script-name "$0"

# Allow automatic applying of outstanding/new migrations on startup
: "${DB_APPLY_NEW_MIGRATIONS_AUTOMATICALLY:=0}"

# Wait for the database to be ready
await-database-ready

# Make sure only one container run the remainder of this script at a time
acquire-lock

# Run the migrate:status command and capture output
output=$(run-as-runtime-user php artisan migrate:status --pending || :)

# By default we have no new migrations
declare -i new_migrations=0

# Detect if any new migrations are available by checking for "Pending" in the output
#
# ! NOTE:
#   Case-sensitivity is important here since the output is [ INFO  No pending migrations. ]
#   in case there are no pending migrations. This is a lower case [p]ending where
#   the 2nd column when there ARE migrations are upper case [P]ending
echo "$output" | grep Pending && new_migrations=1

if is-false "${new_migrations}"; then
    log-info "No new migrations detected"

    exit 0
fi

log-warning "New migrations available"

# Print the output
echo "$output"

if is-false "${DB_APPLY_NEW_MIGRATIONS_AUTOMATICALLY}"; then
    log-info "Automatic applying of new database migrations is disabled"
    log-info "Please set [DB_APPLY_NEW_MIGRATIONS_AUTOMATICALLY=1] in your [.env] file to enable this."

    exit 0
fi

run-as-runtime-user php artisan migrate --force
