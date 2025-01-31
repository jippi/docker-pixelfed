#!/bin/bash
set -e -o errexit -o nounset -o pipefail

declare project_root="${PWD}"

command -v git &>/dev/null && project_root=$(git rev-parse --show-toplevel)

exec docker run -it -v "${project_root}:/var/www" bats/bats:latest /var/www/docker/tests/bats
