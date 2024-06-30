#!/bin/bash
: "${ENTRYPOINT_ROOT:="/docker"}"

# shellcheck source=SCRIPTDIR/../helpers.sh
source "${ENTRYPOINT_ROOT}/helpers.sh"

entrypoint-set-script-name "$0"

# ensure cron file(s) has correct permissions
run-as-current-user chmod --verbose 0644 "/docker/cron/pixelfed"

# load the crontab into the daemon
crontab -u "${runtime_username}" "/docker/cron/pixelfed"

exit 0
