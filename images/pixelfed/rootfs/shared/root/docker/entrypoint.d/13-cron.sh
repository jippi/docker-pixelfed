#!/bin/bash
: "${ENTRYPOINT_ROOT:="/docker"}"

# shellcheck source=SCRIPTDIR/../helpers.sh
source "${ENTRYPOINT_ROOT}/helpers.sh"

entrypoint-set-script-name "$0"

run-as-current-user cp --force "${ENTRYPOINT_ROOT}/cron.d/www-data" "/etc/cron.d/${runtime_username}"
