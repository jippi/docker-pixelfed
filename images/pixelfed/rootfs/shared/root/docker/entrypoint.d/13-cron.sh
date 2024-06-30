#!/bin/bash
: "${ENTRYPOINT_ROOT:="/docker"}"

# shellcheck source=SCRIPTDIR/../helpers.sh
source "${ENTRYPOINT_ROOT}/helpers.sh"

entrypoint-set-script-name "$0"

run-as-current-user cp --force "${ENTRYPOINT_ROOT}/cron.d/pixelfed" "/etc/cron.d/pixelfed"
run-as-current-user chmod --verbose 0644 "/etc/cron.d/pixelfed"

exit 0
