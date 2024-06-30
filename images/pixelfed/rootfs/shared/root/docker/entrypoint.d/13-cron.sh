#!/bin/bash
: "${ENTRYPOINT_ROOT:="/docker"}"

# shellcheck source=SCRIPTDIR/../helpers.sh
source "${ENTRYPOINT_ROOT}/helpers.sh"

entrypoint-set-script-name "$0"

# ensure cron file(s) has correct permissions
run-as-current-user chmod --verbose 0644 "/etc/cron.d/*"

exit 0
