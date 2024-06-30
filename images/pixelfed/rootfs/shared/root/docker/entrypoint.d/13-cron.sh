#!/bin/bash
: "${ENTRYPOINT_ROOT:="/docker"}"

# shellcheck source=SCRIPTDIR/../helpers.sh
source "${ENTRYPOINT_ROOT}/helpers.sh"

entrypoint-set-script-name "$0"

# copy pixelfed cron file
run-as-current-user cp --verbose --force "${ENTRYPOINT_ROOT}/cron.d/pixelfed" "/etc/cron.d/pixelfed"

# ensure cron file(s) has correct permissions
run-as-current-user chmod --verbose 0644 "/etc/cron.d/*"

exit 0
