#!/bin/bash
: "${ENTRYPOINT_ROOT:="/docker"}"

# shellcheck source=SCRIPTDIR/../helpers.sh
source "${ENTRYPOINT_ROOT}/helpers.sh"

entrypoint-set-script-name "$0"

# composer scripts are skipped during image build (--no-scripts), run them here where .env/DB/cache exist
run-as-runtime-user composer run-script post-install-cmd
