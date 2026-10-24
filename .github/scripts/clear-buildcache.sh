#!/usr/bin/env bash
# Delete all versions of the buildcache container package.
# Requires: gh auth refresh -s read:packages,delete:packages
set -euo pipefail

OWNER="${OWNER:-jippi}"
PACKAGE="${PACKAGE:-docker-pixelfed-buildcache}"
BASE="/users/${OWNER}/packages/container/${PACKAGE}"

mapfile -t ids < <(gh api --paginate "${BASE}/versions?per_page=100" --jq '.[].id')

echo "Found ${#ids[@]} versions in ghcr.io/${OWNER}/${PACKAGE}"
[[ ${#ids[@]} -eq 0 ]] && exit 0

if [[ "${1:-}" != "-y" ]]; then
    read -r -p "Delete all of them? [y/N] " answer
    [[ "${answer}" == "y" ]] || exit 1
fi

failed=0
for id in "${ids[@]}"; do
    if gh api -X DELETE "${BASE}/versions/${id}" --silent; then
        echo "deleted ${id}"
    else
        echo "failed ${id}" >&2
        failed=$((failed + 1))
    fi
done

echo "Done, ${failed} failed"
